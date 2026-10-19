import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'db/app_database.dart';
import 'repositories/label_repository.dart';
import 'repositories/project_repository.dart';
import 'repositories/task_repository.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);
  return database;
});

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepository(ref.watch(appDatabaseProvider));
});

final labelRepositoryProvider = Provider<LabelRepository>((ref) {
  return LabelRepository(ref.watch(appDatabaseProvider));
});

final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  return ProjectRepository(ref.watch(appDatabaseProvider));
});

/// Semua tugas tanpa filter pencarian (dipakai Dasbor & statistik).
final allTasksWithLabelsProvider =
    StreamProvider<List<TaskWithLabels>>((ref) {
  return ref.watch(taskRepositoryProvider).watchTasksWithLabels();
});

/// Instance SharedPreferences yang disuntikkan dari main.dart agar
/// pengaturan (urutan tampilan) bisa dipersistenkan.
final sharedPrefsProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'sharedPrefsProvider harus di-override di main.dart / test',
  );
});
