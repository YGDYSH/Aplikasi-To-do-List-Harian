import 'package:drift/drift.dart';

import '../db/app_database.dart';

class TaskWithLabels {
  TaskWithLabels({required this.task, required this.labels});

  final Task task;
  final List<Label> labels;
}

class TaskRepository {
  TaskRepository(this._db);

  final AppDatabase _db;

  Stream<List<Task>> watchTasks({String? query}) {
    final keyword = query?.trim().toLowerCase() ?? '';
    final stream = _db.select(_db.tasks).watch();
    if (keyword.isEmpty) {
      return stream.map((tasks) => tasks.map(_normalizeDateTimes).toList());
    }
    return stream
        .map((tasks) =>
            tasks.where((task) => _matchesTask(task, keyword)).toList())
        .map((tasks) => tasks.map(_normalizeDateTimes).toList());
  }

  /// drift membaca tanggal sebagai waktu lokal; konversi kontrak data ke UTC.
  Task _normalizeDateTimes(Task task) {
    return task.copyWith(
      dueDate: Value(_asUtc(task.dueDate)),
      reminderAt: Value(_asUtc(task.reminderAt)),
      completedAt: Value(_asUtc(task.completedAt)),
      createdAt: _asUtc(task.createdAt),
    );
  }

  DateTime? _asUtc(DateTime? value) {
    if (value == null) return null;
    if (value.isUtc) return value;
    return DateTime.fromMillisecondsSinceEpoch(
      value.millisecondsSinceEpoch,
      isUtc: true,
    );
  }

  bool _matchesTask(Task task, String keyword) {
    final title = task.title.toLowerCase();
    final note = task.note?.toLowerCase() ?? '';
    return title.contains(keyword) || note.contains(keyword);
  }

  Future<List<Task>> getTasks() async {
    final tasks = await _db.select(_db.tasks).get();
    return tasks.map(_normalizeDateTimes).toList();
  }

  /// Satu stream berisi tugas beserta labelnya (UI Bagian 3.4).
  /// Pencarian dan normalisasi tanggal dilakukan di sini agar UI murni.
  Stream<List<TaskWithLabels>> watchTasksWithLabels({String? query}) {
    final keyword = query?.trim().toLowerCase() ?? '';
    final joined = _db.select(_db.tasks).join([
      leftOuterJoin(
        _db.taskLabels,
        _db.taskLabels.taskId.equalsExp(_db.tasks.id),
      ),
      leftOuterJoin(
        _db.labels,
        _db.labels.id.equalsExp(_db.taskLabels.labelId),
      ),
    ])..orderBy([OrderingTerm.asc(_db.tasks.id)]);

    return joined.watch().map((rows) {
      final order = <int>[];
      final tasks = <int, Task>{};
      final labels = <int, List<Label>>{};

      for (final row in rows) {
        final task = _normalizeDateTimes(row.readTable(_db.tasks));
        final taskId = task.id;
        if (!tasks.containsKey(taskId)) {
          order.add(taskId);
          tasks[taskId] = task;
          labels[taskId] = <Label>[];
        }
        if (row.readTableOrNull(_db.labels) case final label?) {
          if (!labels[taskId]!.any((existing) => existing.id == label.id)) {
            labels[taskId]!.add(label);
          }
        }
      }

      return [
        for (final id in order)
          if (keyword.isEmpty ||
              tasks[id]!.title.toLowerCase().contains(keyword) ||
              (tasks[id]!.note?.toLowerCase().contains(keyword) ?? false))
            TaskWithLabels(task: tasks[id]!, labels: labels[id] ?? const []),
      ];
    });
  }

  Future<Task?> getTask(int id) async {
    final query = _db.select(_db.tasks)..where((task) => task.id.equals(id));
    final task = await query.getSingleOrNull();
    return task == null ? null : _normalizeDateTimes(task);
  }

  Future<int> insertTask({
    required String title,
    String? note,
    DateTime? dueDate,
    bool hasTime = false,
    int priority = 0,
    int? projectId,
    DateTime? reminderAt,
    String? repeatRule,
    List<int> labelIds = const [],
  }) async {
    final trimmed = title.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError.value(title, 'title', 'Judul tugas tidak boleh kosong');
    }
    final noteValue = (note == null || note.trim().isEmpty) ? null : note;
    final id = await _db.into(_db.tasks).insert(
          TasksCompanion.insert(
            title: trimmed,
            note: Value(noteValue),
            dueDate: Value(dueDate?.toUtc()),
            hasTime: Value(hasTime),
            priority: Value(priority),
            projectId: Value(projectId),
            reminderAt: Value(reminderAt?.toUtc()),
            repeatRule: Value(repeatRule),
            createdAt: DateTime.now().toUtc(),
          ),
        );
    await setLabelsForTask(id, labelIds);
    return id;
  }

  Future<void> updateTask(int id, TasksCompanion updates) async {
    var normalized = updates;
    final title = updates.title;
    if (title.present) {
      final trimmed = title.value.trim();
      if (trimmed.isEmpty) {
        throw ArgumentError.value(title.value, 'title', 'Judul tugas tidak boleh kosong');
      }
      normalized = updates.copyWith(title: Value(trimmed));
    }
    await (_db.update(_db.tasks)..where((task) => task.id.equals(id)))
        .write(normalized);
  }

  Future<void> setTaskDone(int id, bool done) async {
    await (_db.update(_db.tasks)..where((task) => task.id.equals(id))).write(
          TasksCompanion(
            isDone: Value(done),
            status: Value(done ? 2 : 0),
            completedAt: Value(done ? DateTime.now().toUtc() : null),
          ),
        );
  }

  /// Ubah status tugas dari Kanban (Tahap 5): 0 belum mulai,
  /// 1 dikerjakan, 2 selesai. isDone & completedAt tetap sinkron
  /// (Kontrak Perilaku Bagian 8).
  Future<void> setTaskStatus(int id, int status) async {
    final isDone = status == 2;
    await (_db.update(_db.tasks)..where((task) => task.id.equals(id))).write(
          TasksCompanion(
            status: Value(status),
            isDone: Value(isDone),
            completedAt: Value(isDone ? DateTime.now().toUtc() : null),
          ),
        );
  }

  Future<void> deleteTask(int id) async {
    await (_db.delete(_db.tasks)..where((task) => task.id.equals(id))).go();
  }

  Future<void> setLabelsForTask(int taskId, List<int> labelIds) async {
    await _db.transaction(() async {
      final links = <TaskLabelsCompanion>[
        for (final labelId in labelIds.toSet())
          TaskLabelsCompanion.insert(taskId: taskId, labelId: labelId),
      ];
      await (_db.delete(_db.taskLabels)
            ..where((link) => link.taskId.equals(taskId)))
          .go();
      await _db.batch((batch) {
        if (links.isNotEmpty) {
          batch.insertAll(_db.taskLabels, links);
        }
      });
    });
  }

  /// Satu tugas beserta labelnya (layar ubah tugas Bagian 3.4).
  Stream<TaskWithLabels?> watchTaskWithLabels(int taskId) {
    final joined = _db.select(_db.tasks).join([
      leftOuterJoin(
        _db.taskLabels,
        _db.taskLabels.taskId.equalsExp(_db.tasks.id),
      ),
      leftOuterJoin(
        _db.labels,
        _db.labels.id.equalsExp(_db.taskLabels.labelId),
      ),
    ])..where(_db.tasks.id.equals(taskId));
    return joined.watch().map((rows) {
      if (rows.isEmpty) return null;
      final task = _normalizeDateTimes(rows.first.readTable(_db.tasks));
      final labelIds = <int>{};
      final labels = <Label>[];
      for (final row in rows) {
        final label = row.readTableOrNull(_db.labels);
        if (label != null && labelIds.add(label.id)) labels.add(label);
      }
      return TaskWithLabels(task: task, labels: labels);
    });
  }

  Stream<List<Label>> watchLabelsOfTask(int taskId) {
    final query = _db.select(_db.taskLabels).join(
      [
        innerJoin(_db.labels, _db.labels.id.equalsExp(_db.taskLabels.labelId)),
      ],
    )..where(_db.taskLabels.taskId.equals(taskId));
    return query
        .watch()
        .map((rows) => rows.map((row) => row.readTable(_db.labels)).toList());
  }

  /// Versi sekali-baca untuk duplikasi tugas berulang.
  Future<List<Label>> getLabelsOfTask(int taskId) async {
    final query = _db.select(_db.taskLabels).join(
      [
        innerJoin(_db.labels, _db.labels.id.equalsExp(_db.taskLabels.labelId)),
      ],
    )..where(_db.taskLabels.taskId.equals(taskId));
    final rows = await query.get();
    return [for (final row in rows) row.readTable(_db.labels)];
  }
}
