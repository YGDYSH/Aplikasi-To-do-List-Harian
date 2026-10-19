import 'package:drift/drift.dart';

import '../db/app_database.dart';

class ProjectRepository {
  ProjectRepository(this._db);

  final AppDatabase _db;

  Stream<List<Project>> watchProjects() {
    final query = _db.select(_db.projects)
      ..orderBy([(tbl) => OrderingTerm.asc(tbl.id)]);
    return query.watch();
  }

  Future<List<Project>> getProjects() async {
    final query = _db.select(_db.projects)
      ..orderBy([(tbl) => OrderingTerm.asc(tbl.id)]);
    return query.get();
  }

  /// Menambahkan proyek baru; ikon dipilih dari katalog sederhana.
  Future<int> addProject(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError.value(
        name,
        'name',
        'Nama proyek tidak boleh kosong',
      );
    }
    return _db.into(_db.projects).insert(
          ProjectsCompanion.insert(
            name: trimmed,
            iconKey: iconKeyFallback,
          ),
        );
  }

  static const iconKeyFallback = 'folder';
}
