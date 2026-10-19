import 'package:flutter_test/flutter_test.dart';

import 'package:aplikasi_to_do_list/core/utils/day_stats.dart';
import 'package:aplikasi_to_do_list/data/db/app_database.dart';

Task _task({
  required int id,
  DateTime? dueDateUtc,
  bool isDone = false,
}) {
  return Task(
    id: id,
    title: 'Tugas $id',
    note: null,
    dueDate: dueDateUtc,
    hasTime: false,
    priority: 0,
    status: isDone ? 2 : 0,
    isDone: isDone,
    projectId: null,
    reminderAt: null,
    repeatRule: null,
    completedAt: null,
    createdAt: DateTime(2026),
  );
}

void main() {
  // Zona independen: buat dueDate dari waktu lokal tengah hari lalu
  // simpan sesuai kontrak sebagai UTC.
  final localDay = DateTime(2026, 10, 19, 12);
  final dayUtc = localDay.toUtc();
  final otherDayUtc = localDay.add(const Duration(days: 1)).toUtc();

  test('computeDayStats: selesai/total hanya untuk tugas hari itu', () {
    final stats = computeDayStats(
      [
        _task(id: 1, dueDateUtc: dayUtc, isDone: true),
        _task(id: 2, dueDateUtc: dayUtc),
        _task(id: 3, dueDateUtc: otherDayUtc),
        _task(id: 4),
      ],
      day: localDay,
    );

    expect(stats.totalCount, 2);
    expect(stats.completedCount, 1);
    expect(stats.productivityPercent, 50);
  });

  test('computeDayStats: hari tanpa tugas → 0 dan 0%', () {
    final stats = computeDayStats(
      [_task(id: 1, dueDateUtc: otherDayUtc)],
      day: localDay,
    );
    expect(stats.totalCount, 0);
    expect(stats.completedCount, 0);
    expect(stats.productivityPercent, 0);
  });

  test('computeDayStats: 4 selesai dari 2 tugas → tidak melebihi 100', () {
    final stats = computeDayStats(
      [
        _task(id: 1, dueDateUtc: dayUtc, isDone: true),
      ],
      day: localDay,
    );
    expect(stats.productivityPercent, 100);
  });

  test('tasksDueOnDay: filter tanggal lokal (dueDate UTC)', () {
    final result = tasksDueOnDay(
      [
        _task(id: 1, dueDateUtc: dayUtc),
        _task(id: 2, dueDateUtc: otherDayUtc),
        _task(id: 3, dueDateUtc: null),
      ],
      day: localDay,
    );

    expect(result, hasLength(1));
    expect(result.first.id, 1);
  });

  test('tasksDueOnDay: tugas dengan jam pagi masih dalam hari yang sama', () {
    // 19 Okt 2026 09:00 lokal, tetap hari yang sama.
    final morningUtc = DateTime(2026, 10, 19, 9).toUtc();
    final result = tasksDueOnDay(
      [_task(id: 5, dueDateUtc: morningUtc)],
      day: localDay,
    );
    expect(result, hasLength(1));
  });
}
