import 'package:flutter_test/flutter_test.dart';

import 'package:aplikasi_to_do_list/core/constants/app_strings.dart';
import 'package:aplikasi_to_do_list/core/utils/task_grouping.dart';
import 'package:aplikasi_to_do_list/data/db/app_database.dart';

Task _task({
  required int id,
  String title = 'Tugas',
  DateTime? dueDate,
  bool isDone = false,
  int priority = 0,
}) {
  return Task(
    id: id,
    title: title,
    hasTime: false,
    priority: priority,
    status: isDone ? 2 : 0,
    isDone: isDone,
    createdAt: DateTime.utc(2026, 1, 1),
    dueDate: dueDate,
  );
}

void main() {
  final now = DateTime.utc(2026, 10, 19, 10);

  test('mengelompokkan tugas ke semua grup berurutan', () {
    final tasks = [
      _task(id: 1, dueDate: DateTime.utc(2026, 10, 19)),
      _task(id: 2, dueDate: DateTime.utc(2026, 10, 20)),
      _task(id: 3, dueDate: DateTime.utc(2026, 10, 22)),
      _task(id: 4, dueDate: DateTime.utc(2026, 10, 30)),
      _task(id: 5),
      _task(id: 6, dueDate: DateTime.utc(2026, 10, 15)),
    ];

    final groups = groupTasks(tasks, now: now);

    expect(groups.map((group) => group.key), [
      TaskGroupKey.today,
      TaskGroupKey.tomorrow,
      TaskGroupKey.thisWeek,
      TaskGroupKey.later,
      TaskGroupKey.noDate,
    ]);
    expect(groups[0].title, AppStrings.groupToday);
    expect(groups[1].title, AppStrings.groupTomorrow);
    expect(groups[2].title, AppStrings.groupThisWeek);
    expect(groups[3].title, AppStrings.groupLater);
    expect(groups[4].title, AppStrings.groupNoDate);
    expect(groups[0].tasks.map((task) => task.id), [6, 1]);
    expect(groups[1].tasks.map((task) => task.id), [2]);
    expect(groups[2].tasks.map((task) => task.id), [3]);
    expect(groups[3].tasks.map((task) => task.id), [4]);
    expect(groups[4].tasks.map((task) => task.id), [5]);
    expect(groups[0].overdueTaskIds, {6});
  });

  test('tugas terlambat yang sudah selesai tidak ditandai', () {
    final groups = groupTasks(
      [_task(id: 1, dueDate: DateTime.utc(2026, 10, 15), isDone: true)],
      now: now,
    );

    expect(groups.single.key, TaskGroupKey.today);
    expect(groups.single.overdueTaskIds, isEmpty);
    expect(groups.single.tasks.single.id, 1);
  });

  test('tugas dengan jam tetap masuk grup Hari Ini', () {
    final groups = groupTasks(
      [_task(id: 1, dueDate: DateTime.utc(2026, 10, 19, 6))],
      now: now,
    );

    expect(groups.single.key, TaskGroupKey.today);
    expect(groups.single.overdueTaskIds, isEmpty);
  });

  test('aman jika hari ini adalah hari Minggu', () {
    final sunday = DateTime.utc(2026, 10, 25, 10);
    final groups = groupTasks(
      [
        _task(id: 1, dueDate: DateTime.utc(2026, 10, 26)),
        _task(id: 2, dueDate: DateTime.utc(2026, 10, 28)),
      ],
      now: sunday,
    );

    expect(groups.map((group) => group.key), [
      TaskGroupKey.tomorrow,
      TaskGroupKey.later,
    ]);
  });

  test('aman jika hari ini adalah hari Sabtu', () {
    final saturday = DateTime.utc(2026, 10, 24, 10);
    final groups = groupTasks(
      [
        _task(id: 1, dueDate: DateTime.utc(2026, 10, 25)),
        _task(id: 2, dueDate: DateTime.utc(2026, 10, 27)),
      ],
      now: saturday,
    );

    expect(groups.map((group) => group.key), [
      TaskGroupKey.tomorrow,
      TaskGroupKey.later,
    ]);
  });

  test('grup tidak muncul bila tidak ada tugasnya', () {
    final groups = groupTasks(
      [_task(id: 1, dueDate: DateTime.utc(2026, 10, 30))],
      now: now,
    );

    expect(groups.length, 1);
    expect(groups.single.key, TaskGroupKey.later);
  });

  test('tanpa tugas menghasilkan daftar grup kosong', () {
    expect(groupTasks(const [], now: now), isEmpty);
  });

  test('tugas selesai diurutkan di akhir grup', () {
    final groups = groupTasks(
      [
        _task(id: 1, dueDate: DateTime.utc(2026, 10, 19, 6), isDone: true),
        _task(id: 2, dueDate: DateTime.utc(2026, 10, 19, 8)),
      ],
      now: now,
    );

    expect(groups.single.tasks.map((task) => task.id), [2, 1]);
  });

  test('prioritas tinggi dan id kecil diurutkan lebih dulu', () {
    final groups = groupTasks(
      [
        _task(id: 3, dueDate: DateTime.utc(2026, 10, 19), priority: 0),
        _task(id: 2, dueDate: DateTime.utc(2026, 10, 19), priority: 2),
        _task(id: 1, dueDate: DateTime.utc(2026, 10, 19), priority: 2),
      ],
      now: now,
    );

    expect(groups.single.tasks.map((task) => task.id), [1, 2, 3]);
  });
}
