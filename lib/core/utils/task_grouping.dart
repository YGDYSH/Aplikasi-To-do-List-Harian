import 'package:aplikasi_to_do_list/core/constants/app_strings.dart';
import 'package:aplikasi_to_do_list/data/db/app_database.dart';

import 'date_utils.dart';

enum TaskGroupKey {
  today,
  tomorrow,
  thisWeek,
  later,
  noDate,
}

class TaskGroupSection {
  const TaskGroupSection({
    required this.key,
    required this.title,
    required this.tasks,
    required this.overdueTaskIds,
  });

  final TaskGroupKey key;
  final String title;
  final List<Task> tasks;

  /// Id tugas belum selesai yang jatuh tempo sebelum hari ini
  /// (ditandai merah di UI Bagian 3.4).
  final Set<int> overdueTaskIds;

  bool get isEmpty => tasks.isEmpty;
  bool get isNotEmpty => tasks.isNotEmpty;
}

/// Fungsi murni: menentukan kelompok tugas (aturan desain Bagian 7).
///
/// - Hari Ini: jatuh tempo hari ini, termasuk tugas TERLAMBAT (belum
///   selesai, sebelum hari ini).
/// - Besok: tanggal besok.
/// - Minggu Ini: setelah besok sampai akhir minggu (diakhiri hari Minggu).
/// - Nanti: setelah minggu ini. Tanpa Tanggal: dueDate null.
///
/// Tugas selesai yang jatuh tempo sebelum hari ini tetap masuk Hari Ini
/// tetapi TIDAK dianggap terlambat.
TaskGroupKey classifyTask({
  required DateTime? dueDate,
  required bool isDone,
  required DateTime now,
}) {
  if (dueDate == null) return TaskGroupKey.noDate;

  final todayStart = TugaskuDateUtils.startOfDay(now);
  final dueStart = TugaskuDateUtils.startOfDay(dueDate);

  if (dueStart.isBefore(todayStart)) {
    return TaskGroupKey.today;
  }
  if (TugaskuDateUtils.isSameDay(dueDate, now)) {
    return TaskGroupKey.today;
  }
  if (TugaskuDateUtils.isSameDay(dueDate, TugaskuDateUtils.tomorrow(now))) {
    return TaskGroupKey.tomorrow;
  }
  if (!dueDate.isAfter(TugaskuDateUtils.endOfWeek(now))) {
    return TaskGroupKey.thisWeek;
  }
  return TaskGroupKey.later;
}

bool isTaskOverdue({
  required DateTime? dueDate,
  required bool isDone,
  required DateTime now,
}) {
  if (dueDate == null || isDone) return false;
  return TugaskuDateUtils.startOfDay(dueDate)
      .isBefore(TugaskuDateUtils.startOfDay(now));
}

String taskGroupTitle(TaskGroupKey key) {
  switch (key) {
    case TaskGroupKey.today:
      return AppStrings.groupToday;
    case TaskGroupKey.tomorrow:
      return AppStrings.groupTomorrow;
    case TaskGroupKey.thisWeek:
      return AppStrings.groupThisWeek;
    case TaskGroupKey.later:
      return AppStrings.groupLater;
    case TaskGroupKey.noDate:
      return AppStrings.groupNoDate;
  }
}

/// Fungsi murni: mengelompokkan tugas ke seksi berurutan.
/// Seksi tanpa tugas tidak muncul.
///
/// Urutan dalam seksi: belum selesai dulu, terlambat dulu, prioritas
/// tinggi dulu, lalu id terkecil dulu.
List<TaskGroupSection> groupTasks(
  List<Task> tasks, {
  required DateTime now,
}) {
  final grouped = <TaskGroupKey, List<Task>>{};
  final overdueIds = <TaskGroupKey, Set<int>>{};

  for (final task in tasks) {
    final key = classifyTask(
      dueDate: task.dueDate,
      isDone: task.isDone,
      now: now,
    );
    grouped.putIfAbsent(key, () => []).add(task);
    if (isTaskOverdue(
      dueDate: task.dueDate,
      isDone: task.isDone,
      now: now,
    )) {
      overdueIds.putIfAbsent(key, () => {}).add(task.id);
    }
  }

  final keys = grouped.keys.toList()..sort((a, b) => a.index - b.index);

  return [
    for (final key in keys)
      TaskGroupSection(
        key: key,
        title: taskGroupTitle(key),
        tasks: _sortTasks(grouped[key]!, overdueIds[key] ?? const {}),
        overdueTaskIds: overdueIds[key] ?? const {},
      ),
  ];
}

List<Task> _sortTasks(List<Task> tasks, Set<int> overdueIds) {
  final list = List<Task>.of(tasks);
  int compare(Task a, Task b) {
    if (a.isDone != b.isDone) return a.isDone ? 1 : -1;
    final aOverdue = overdueIds.contains(a.id);
    final bOverdue = overdueIds.contains(b.id);
    if (aOverdue != bOverdue) return aOverdue ? -1 : 1;
    if (a.priority != b.priority) return b.priority.compareTo(a.priority);
    return a.id.compareTo(b.id);
  }

  list.sort(compare);
  return list;
}
