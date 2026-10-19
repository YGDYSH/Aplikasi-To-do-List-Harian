import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/day_stats.dart';
import '../../../data/repositories/task_repository.dart';
import '../../../data/providers.dart';

/// Statistik tugas **hari ini** (WIB lokal) untuk kartu empty state.
final dayStatsProvider = Provider<DayStats>((ref) {
  return dayStatsFor(
    ref.watch(allTasksWithLabelsProvider).value ?? const [],
    day: DateTime.now(),
  );
});

/// Statistik untuk satu hari tertentu (waktu lokal, mis. kalender).
DayStats dayStatsFor(
  List<TaskWithLabels> items, {
  required DateTime day,
}) {
  return computeDayStats(
    [for (final item in items) item.task],
    day: day,
  );
}
