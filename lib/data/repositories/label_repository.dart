import 'package:drift/drift.dart';

import '../db/app_database.dart';

class LabelRepository {
  LabelRepository(this._db);

  final AppDatabase _db;

  Stream<List<Label>> watchLabels() => _db.select(_db.labels).watch();

  Future<List<Label>> getLabels() => _db.select(_db.labels).get();

  Future<Label?> getLabel(int id) {
    final query = _db.select(_db.labels)..where((label) => label.id.equals(id));
    return query.getSingleOrNull();
  }

  Future<int> createLabel({required String name, required int colorValue}) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError.value(name, 'name', 'Nama label tidak boleh kosong');
    }
    final existing = await (_db.select(_db.labels)
          ..where(
            (label) => label.name.lower().equals(trimmed.toLowerCase()),
          ))
        .getSingleOrNull();
    if (existing != null) {
      throw StateError('Label "$trimmed" sudah ada');
    }
    return _db
        .into(_db.labels)
        .insert(LabelsCompanion.insert(name: trimmed, colorValue: colorValue));
  }

  Future<void> updateLabel(int id, {String? name, int? colorValue}) async {
    if (name == null && colorValue == null) return;
    final trimmed = name?.trim();
    if (trimmed != null && trimmed.isEmpty) {
      throw ArgumentError.value(name, 'name', 'Nama label tidak boleh kosong');
    }
    await (_db.update(_db.labels)..where((label) => label.id.equals(id))).write(
          LabelsCompanion(
            name: trimmed == null ? const Value.absent() : Value(trimmed),
            colorValue:
                colorValue == null ? const Value.absent() : Value(colorValue),
          ),
        );
  }

  Future<void> deleteLabel(int id) async {
    await (_db.delete(_db.labels)..where((label) => label.id.equals(id))).go();
  }
}
