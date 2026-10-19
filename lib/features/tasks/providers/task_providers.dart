import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/utils/repeat_rule.dart';
import '../../../core/utils/task_grouping.dart';
import '../../../data/db/app_database.dart';
import '../../../data/providers.dart';
import '../../../data/repositories/task_repository.dart';
import '../../../services/notification_service.dart';

final searchQueryProvider = StateProvider<String>((ref) => '');

enum SortOption { dueDate, priority, label, project }

String sortOptionLabel(SortOption option) {
  switch (option) {
    case SortOption.dueDate:
      return AppStrings.sortDueDate;
    case SortOption.priority:
      return AppStrings.sortPriority;
    case SortOption.label:
      return AppStrings.sortLabel;
    case SortOption.project:
      return AppStrings.sortProject;
  }
}

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService.instance;
});

final sortOptionProvider =
    NotifierProvider<SortOptionController, SortOption>(
  SortOptionController.new,
);

/// Pilihan urutan tampilan dipersistenkan di shared_preferences.
class SortOptionController extends Notifier<SortOption> {
  static const _prefsKey = 'task_sort_option';

  @override
  SortOption build() {
    final prefs = ref.watch(sharedPrefsProvider);
    final index = prefs.getInt(_prefsKey);
    if (index != null && index >= 0 && index < SortOption.values.length) {
      return SortOption.values[index];
    }
    return SortOption.dueDate;
  }

  void select(SortOption option) {
    state = option;
    ref.read(sharedPrefsProvider).setInt(_prefsKey, option.index);
  }
}

class GroupedTasksState {
  const GroupedTasksState({
    required this.sections,
    required this.itemsById,
  });

  final List<TaskGroupSection> sections;
  final Map<int, TaskWithLabels> itemsById;

  int get taskCount => sections.fold<int>(
        0,
        (total, section) => total + section.tasks.length,
      );

  bool get isEmpty => taskCount == 0;
}

final groupedTasksProvider =
    NotifierProvider<GroupedTasksController, AsyncValue<GroupedTasksState>>(
  GroupedTasksController.new,
);

class GroupedTasksController
    extends Notifier<AsyncValue<GroupedTasksState>> {
  @override
  AsyncValue<GroupedTasksState> build() {
    final query = ref.watch(searchQueryProvider);
    final stream =
        ref.watch(taskRepositoryProvider).watchTasksWithLabels(query: query);

    final subscription = stream.listen((items) {
      state = AsyncData(_group(items));
    });
    ref.onDispose(subscription.cancel);

    return const AsyncLoading();
  }

  GroupedTasksState _group(List<TaskWithLabels> items) {
    final now = DateTime.now();
    final option = ref.watch(sortOptionProvider);
    final byId = <int, TaskWithLabels>{
      for (final item in items) item.task.id: item,
    };
    final sections = groupTasks(
      [for (final item in items) item.task],
      now: now,
    );

    return GroupedTasksState(
      itemsById: byId,
      sections: [
        for (final section in sections)
          TaskGroupSection(
            key: section.key,
            title: section.title,
            tasks: _sortForOption(option, section.tasks, items: byId),
            overdueTaskIds: section.overdueTaskIds,
          ),
      ],
    );
  }

  List<Task> _sortForOption(
    SortOption option,
    List<Task> tasks, {
    required Map<int, TaskWithLabels> items,
  }) {
    final list = List<Task>.of(tasks);
    list.sort((a, b) {
      if (a.isDone != b.isDone) return a.isDone ? 1 : -1;
      final comparison = switch (option) {
        SortOption.dueDate => _compareDueDate(a, b),
        SortOption.priority => b.priority.compareTo(a.priority),
        SortOption.label => _compareLabel(a, b, items),
        SortOption.project => _compareProject(a, b),
      };
      if (comparison != 0) return comparison;
      return a.id.compareTo(b.id);
    });
    return list;
  }

  int _compareDueDate(Task a, Task b) {
    final aDate = a.dueDate;
    final bDate = b.dueDate;
    if ((aDate == null) != (bDate == null)) return aDate == null ? 1 : -1;
    if (aDate != null && bDate != null) {
      final byDate = aDate.compareTo(bDate);
      if (byDate != 0) return byDate;
    }
    return 0;
  }

  int _compareLabel(
    Task a,
    Task b,
    Map<int, TaskWithLabels> items,
  ) {
    final aLabel = _firstLabelName(items[a.id]);
    final bLabel = _firstLabelName(items[b.id]);
    if (aLabel == null && bLabel == null) return 0;
    if (aLabel == null) return 1;
    if (bLabel == null) return -1;
    return aLabel.compareTo(bLabel);
  }

  String? _firstLabelName(TaskWithLabels? item) {
    final labels = item?.labels;
    if (labels == null || labels.isEmpty) return null;
    return labels.first.name.toLowerCase();
  }

  int _compareProject(Task a, Task b) {
    final aProject = a.projectId;
    final bProject = b.projectId;
    if ((aProject == null) != (bProject == null)) {
      return aProject == null ? 1 : -1;
    }
    if (aProject != null && bProject != null) {
      return aProject.compareTo(bProject);
    }
    return 0;
  }

  void setQuery(String value) {
    ref.read(searchQueryProvider.notifier).state = value;
  }

  Future<void> toggleDone(int taskId, {required bool done}) async {
    final previous = await ref.read(taskRepositoryProvider).getTask(taskId);
    await ref.read(taskRepositoryProvider).setTaskDone(taskId, done);
    // Tugas berulang (Tahap 5): selesai → buat instance berikutnya.
    if (done && previous != null && previous.repeatRule != null) {
      await _spawnNextRepetition(previous);
    }
    await _syncReminderByTaskId(taskId);
  }

  /// Memindahkan tugas antar kolom Kanban (status 0/1/2).
  Future<void> moveTaskToStatus(int taskId, int status) async {
    await ref.read(taskRepositoryProvider).setTaskStatus(taskId, status);
    await _syncReminderByTaskId(taskId);
  }

  /// Duplikasi tugas berulang: tanggal (dan pengingat) maju sesuai aturan.
  Future<void> _spawnNextRepetition(Task task) async {
    final dueDate = task.dueDate;
    final delta = repeatDeltaDays(task.repeatRule);
    if (dueDate == null || delta <= 0) return;

    final repo = ref.read(taskRepositoryProvider);
    final shiftedDue = dueDate.add(Duration(days: delta));
    final reminderAt = task.reminderAt;
    final shiftedReminder =
        reminderAt?.add(Duration(days: delta));
    final labels = await repo.getLabelsOfTask(task.id);

    final newId = await repo.insertTask(
      title: task.title,
      note: task.note,
      dueDate: shiftedDue,
      hasTime: task.hasTime,
      priority: task.priority,
      reminderAt: shiftedReminder,
      repeatRule: task.repeatRule,
      projectId: task.projectId,
      labelIds: [for (final label in labels) label.id],
    );
    if (shiftedReminder != null) {
      await _scheduleReminder(newId, shiftedReminder);
    }
  }

  Future<int> addTask({
    required String title,
    String? note,
    DateTime? dueDate,
    bool hasTime = false,
    int priority = 0,
    DateTime? reminderAt,
    String? repeatRule,
    List<int> labelIds = const [],
  }) async {
    final id = await ref.read(taskRepositoryProvider).insertTask(
          title: title,
          note: note,
          dueDate: dueDate,
          hasTime: hasTime,
          priority: priority,
          reminderAt: reminderAt,
          repeatRule: isRepeatRuleValid(repeatRule) ? repeatRule : null,
          labelIds: labelIds,
        );
    await _syncReminderByTaskId(id);
    return id;
  }

  Future<void> updateFields({
    required int taskId,
    required String title,
    String? note,
    DateTime? dueDate,
    bool hasTime = false,
    int priority = 0,
    DateTime? reminderAt,
    String? repeatRule,
  }) async {
    await ref.read(taskRepositoryProvider).updateTask(
          taskId,
          TasksCompanion(
            title: Value(title.trim()),
            note: Value(note),
            dueDate: Value(dueDate?.toUtc()),
            hasTime: Value(hasTime && dueDate != null),
            priority: Value(priority),
            reminderAt: Value(reminderAt?.toUtc()),
            repeatRule:
                Value(isRepeatRuleValid(repeatRule) ? repeatRule : null),
          ),
        );
    await _syncReminderByTaskId(taskId);
  }

  /// Jadwalkan ulang / batalkan pengingat setelah data tugas berubah.
  Future<void> _syncReminderByTaskId(int taskId) async {
    final task = await ref.read(taskRepositoryProvider).getTask(taskId);
    if (task == null) {
      await _cancelReminder(taskId);
      return;
    }
    if (task.isDone || task.reminderAt == null) {
      await _cancelReminder(taskId);
    } else {
      await _scheduleReminder(taskId, task.reminderAt!);
    }
  }

  Future<void> setLabels(int taskId, List<int> labelIds) {
    return ref.read(taskRepositoryProvider).setLabelsForTask(taskId, labelIds);
  }

  /// Menghapus tugas dan mengembalikan data untuk aksi Urungkan.
  Future<void> deleteTask(TaskWithLabels item) async {
    final snapshot = TaskWithLabels(
      task: item.task,
      labels: item.labels,
    );
    await _cancelReminder(item.task.id);
    await ref.read(taskRepositoryProvider).deleteTask(item.task.id);
    _lastDeleted = snapshot;
  }

  TaskWithLabels? _lastDeleted;
  TaskWithLabels? get lastDeletedTask => _lastDeleted;

  Future<void> restoreDeleted() async {
    final snapshot = _lastDeleted;
    if (snapshot == null) return;
    final repo = ref.read(taskRepositoryProvider);
    final newId = await repo.insertTask(
      title: snapshot.task.title,
      note: snapshot.task.note,
      dueDate: snapshot.task.dueDate,
      hasTime: snapshot.task.hasTime,
      priority: snapshot.task.priority,
      reminderAt: snapshot.task.reminderAt,
      repeatRule: snapshot.task.repeatRule,
    );
    await repo.setLabelsForTask(
      newId,
      [for (final label in snapshot.labels) label.id],
    );
    // Pengingat dipulihkan dengan id baru.
    if (snapshot.task.reminderAt != null && !snapshot.task.isDone) {
      await _scheduleReminder(newId, snapshot.task.reminderAt!);
    }
    _lastDeleted = null;
  }

  Future<void> _scheduleReminder(int taskId, DateTime reminderAt) {
    return ref
        .read(notificationServiceProvider)
        .scheduleTaskReminder(taskId: taskId, reminderAt: reminderAt);
  }

  Future<void> _cancelReminder(int taskId) {
    return ref.read(notificationServiceProvider).cancelTaskReminder(taskId);
  }
}

final labelsStreamProvider = StreamProvider<List<Label>>((ref) {
  return ref.watch(labelRepositoryProvider).watchLabels();
});

final taskDetailProvider =
    StreamProvider.autoDispose.family<TaskWithLabels?, int>((ref, taskId) {
  return ref.watch(taskRepositoryProvider).watchTaskWithLabels(taskId);
});

String groupBadgeText(int count) => '$count ${AppStrings.taskUnit}';

String priorityValueLabel(int priority) {
  switch (priority) {
    case 2:
      return AppStrings.priorityHigh;
    case 1:
      return AppStrings.priorityMedium;
    default:
      return AppStrings.priorityLow;
  }
}

String repeatValueLabel(String? repeatRule) => repeatRuleLabel(repeatRule);
