import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'db/app_database.dart';
import 'repositories/label_repository.dart';
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
