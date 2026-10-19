import 'dart:convert';

import 'package:drift/drift.dart';

import '../db/app_database.dart';

/// Cadangan data ke/dari JSON (Tahap 5). Data dipindah melalui
/// clipboard oleh UI — tidak ada file/backend (100% offline).
///
/// Job: berisi semua tugas, label, dan tautan label.
/// Impor bersifat merge (tanpa menghapus data lama): label dicocokkan
/// berdasarkan nama (dibuat bila belum ada), setiap tugas di-insert
/// dengan id database baru.
class BackupRepository {
  BackupRepository(this._db);

  final AppDatabase _db;

  static const formatVersion = 1;
  static const _fallbackLabelColor = 0xFF8B83F5;

  Future<String> exportJson() async {
    final tasks = await _db.select(_db.tasks).get();
    final labels = await _db.select(_db.labels).get();
    final links = await _db.select(_db.taskLabels).get();

    final labelNameById = {for (final label in labels) label.id: label.name};

    final payload = <String, Object?>{
      'app': 'tugasku',
      'version': formatVersion,
      'labels': [
        for (final label in labels)
          {
            'name': label.name,
            'colorValue': label.colorValue,
          },
      ],
      'tasks': [
        for (final task in tasks)
          {
            'title': task.title,
            'note': task.note,
            'dueDate': task.dueDate?.toIso8601String(),
            'hasTime': task.hasTime,
            'priority': task.priority,
            'status': task.status,
            'repeatRule': task.repeatRule,
            'completedAt': task.completedAt?.toIso8601String(),
            'createdAt': task.createdAt.toIso8601String(),
            'labels': [
              for (final link in links)
                if (link.taskId == task.id)
                  if (labelNameById[link.labelId] != null)
                    labelNameById[link.labelId],
            ],
          },
      ],
    };

    return jsonEncode(payload);
  }

  /// Mengimpor JSON hasil [exportJson]; mengembalikan jumlah tugas baru.
  /// Melempar [ArgumentError] bila format tidak dikenali.
  Future<int> importJson(String source) async {
    final dynamic decoded = jsonDecode(source);
    if (decoded is! Map<String, dynamic>) {
      throw ArgumentError('payload bukan objek JSON');
    }
    if (decoded['app'] != 'tugasku' || decoded['tasks'] is! List) {
      throw ArgumentError('payload bukan cadangan Tugasku');
    }
    final taskPayloads = decoded['tasks'] as List;
    final labelPayloads = decoded['labels'];

    return _db.transaction(() async {
      // ---------- labels ----------
      final existing = await _db.select(_db.labels).get();
      final labelIdByLowerName = {
        for (final label in existing) label.name.toLowerCase(): label.id,
      };
      if (labelPayloads is List) {
        for (final payload in labelPayloads) {
          if (payload is! Map<String, dynamic>) continue;
          final name = (payload['name'] as String?)?.trim();
          if (name == null || name.isEmpty) continue;
          final colorValue =
              (payload['colorValue'] as num?)?.toInt() ?? _fallbackLabelColor;
          if (colorValue == _fallbackLabelColor &&
              labelIdByLowerName.containsKey(name.toLowerCase())) {
            continue;
          }
          final lower = name.toLowerCase();
          if (labelIdByLowerName.containsKey(lower)) {
            final id = labelIdByLowerName[lower]!;
            await (_db.update(_db.labels)
                  ..where((row) => row.id.equals(id)))
                .write(LabelsCompanion(colorValue: Value(colorValue)));
          } else {
            final id = await _db.into(_db.labels).insert(
                  LabelsCompanion.insert(name: name, colorValue: colorValue),
                );
            labelIdByLowerName[lower] = id;
          }
        }
      }

      // ---------- tasks ----------
      var imported = 0;
      for (final payload in taskPayloads) {
        if (payload is! Map<String, dynamic>) continue;
        final title = (payload['title'] as String?)?.trim();
        if (title == null || title.isEmpty) continue;
        final note = (payload['note'] as String?)?.trim();
        final labelIds = [
          if (payload['labels'] is List)
            for (final rawName in payload['labels'] as List)
              if (rawName is String)
                labelIdByLowerName[rawName.toLowerCase()],
        ];

        final taskId = await _db.into(_db.tasks).insert(
              TasksCompanion.insert(
                title: title,
                note: Value(note == null || note.isEmpty ? null : note),
                dueDate: Value(_parseDateTime(payload['dueDate'])),
                hasTime: Value((payload['hasTime'] as bool?) ?? false),
                priority: Value((payload['priority'] as num?)?.toInt() ?? 0),
                status: Value((payload['status'] as num?)?.toInt() ?? 0),
                repeatRule: Value(payload['repeatRule'] as String?),
                reminderAt: Value(_parseDateTime(payload['reminderAt'])),
                completedAt: Value(_parseDateTime(payload['completedAt'])),
                createdAt: _parseDateTime(payload['createdAt']) ??
                    DateTime.now().toUtc(),
              ),
            );
        imported++;

        final links = <TaskLabelsCompanion>[
          for (final labelId in labelIds)
            // Nama label yang tidak dikenali diabaikan.
            if (labelId != null)
              TaskLabelsCompanion.insert(taskId: taskId, labelId: labelId),
        ];
        if (links.isNotEmpty) {
          await _db.batch((batch) {
            batch.insertAll(_db.taskLabels, links);
          });
        }
      }
      return imported;
    });
  }

  DateTime? _parseDateTime(Object? raw) {
    if (raw is! String || raw.isEmpty) return null;
    final parsed = DateTime.tryParse(raw);
    return parsed?.toUtc();
  }
}
