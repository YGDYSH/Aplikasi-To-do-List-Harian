import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../core/theme/app_colors.dart';
import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Tasks, Labels, TaskLabels, Projects])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator migrator) async {
          await migrator.createAll();
          await _seedLabels();
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  Future<void> _seedLabels() {
    return batch((batch) {
      batch.insertAll(labels, <LabelsCompanion>[
        LabelsCompanion.insert(
          name: 'Belajar',
          colorValue: AppColors.labelBelajar.toARGB32(),
        ),
        LabelsCompanion.insert(
          name: 'Olahraga',
          colorValue: AppColors.labelOlahraga.toARGB32(),
        ),
        LabelsCompanion.insert(
          name: 'Kerja',
          colorValue: AppColors.labelKerja.toARGB32(),
        ),
        LabelsCompanion.insert(
          name: 'Pribadi',
          colorValue: AppColors.labelPribadi.toARGB32(),
        ),
        LabelsCompanion.insert(
          name: 'Kebiasaan',
          colorValue: AppColors.labelKebiasaan.toARGB32(),
        ),
      ]);
    });
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final file = File(p.join(documentsDirectory.path, 'tugasku.db'));
    return NativeDatabase(file);
  });
}
