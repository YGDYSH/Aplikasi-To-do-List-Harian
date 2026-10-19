import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/db/app_database.dart';
import '../../../data/providers.dart';

/// Semua proyek (tabel Projects).
final projectsStreamProvider = StreamProvider<List<Project>>((ref) {
  return ref.watch(projectRepositoryProvider).watchProjects();
});

/// Jumlah tugas per proyek (proyekId -> count).
final projectTaskCountsProvider = Provider<Map<int, int>>((ref) {
  final items = ref.watch(allTasksWithLabelsProvider).value;
  if (items == null) return const {};
  final counts = <int, int>{};
  for (final item in items) {
    final projectId = item.task.projectId;
    if (projectId == null) continue;
    counts[projectId] = (counts[projectId] ?? 0) + 1;
  }
  return counts;
});

/// Jumlah tugas per label (labelId -> count).
final labelTaskCountsProvider = Provider<Map<int, int>>((ref) {
  final items = ref.watch(allTasksWithLabelsProvider).value;
  if (items == null) return const {};
  final counts = <int, int>{};
  for (final item in items) {
    for (final label in item.labels) {
      counts[label.id] = (counts[label.id] ?? 0) + 1;
    }
  }
  return counts;
});

/// Jumlah tugas per status (0 belum mulai, 1 dikerjakan, 2 selesai).
final statusCountsProvider = Provider<Map<int, int>>((ref) {
  final items = ref.watch(allTasksWithLabelsProvider).value;
  if (items == null) return const {};
  final counts = <int, int>{};
  for (final item in items) {
    counts[item.task.status] = (counts[item.task.status] ?? 0) + 1;
  }
  return counts;
});
