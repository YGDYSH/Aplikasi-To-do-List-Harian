import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/providers.dart';
import '../../../data/repositories/task_repository.dart';

/// Hari terpilih di kalender (waktu lokal).
final calendarSelectedDayProvider = StateProvider<DateTime>((_) {
  return DateTime.now();
});

/// Pencarian pada layar Kalender ("Cari jadwal atau tugas...").
final calendarSearchQueryProvider = StateProvider<String>((_) => '');

/// Semua tugas (beserta label) setelah filter pencarian Kalender.
final calendarTasksProvider = StreamProvider<List<TaskWithLabels>>((ref) {
  final query = ref.watch(calendarSearchQueryProvider);
  return ref.watch(taskRepositoryProvider).watchTasksWithLabels(query: query);
});
