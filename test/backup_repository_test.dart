import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aplikasi_to_do_list/data/db/app_database.dart';
import 'package:aplikasi_to_do_list/data/repositories/backup_repository.dart';
import 'package:aplikasi_to_do_list/data/repositories/task_repository.dart';

void main() {
  late AppDatabase db;
  late BackupRepository backupRepository;
  late TaskRepository taskRepository;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    backupRepository = BackupRepository(db);
    taskRepository = TaskRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  Future<int> buatTugas({
    required String title,
    DateTime? dueDate,
    String? repeatRule,
    List<String> labelNames = const [],
  }) async {
    final labels = await db.select(db.labels).get();
    final kunciLabelByNama = {
      for (final label in labels) label.name: label.id,
    };
    return taskRepository.insertTask(
      title: title,
      dueDate: dueDate,
      repeatRule: repeatRule,
      labelIds: [
        for (final name in labelNames)
          if (kunciLabelByNama[name] != null) kunciLabelByNama[name]!,
      ],
    );
  }

  test('impor JSON mengembalikan jumlah tugas & label merge tanpa duplikat',
      () async {
    await buatTugas(
      title: 'Belajar',
      dueDate: DateTime(2026, 10, 14, 9),
      labelNames: ['Olahraga'],
    );
    final json = await backupRepository.exportJson();

    // Impor ke database kosong.
    final db2 = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db2.close);
    final target = BackupRepository(db2);

    final imported = await target.importJson(json);
    expect(imported, 1);

    final tasks = await db2.select(db2.tasks).get();
    expect(tasks, hasLength(1));
    expect(tasks.single.title, 'Belajar');
    // Nilai tanggal kembali sama (bacaan drift native = local).
    expect(tasks.single.dueDate, DateTime(2026, 10, 14, 9));
    // Label seed db2 sudah 5; 'Olahraga' merge tanpa duplikat.
    final labels = await db2.select(db2.labels).get();
    expect(
      labels.map((label) => label.name),
      contains('Olahraga'),
    );
    final labelsOlahraga = labels
        .where((label) => label.name == 'Olahraga')
        .toList();
    expect(labelsOlahraga, hasLength(1));

    final links = await db2.select(db2.taskLabels).get();
    expect(links, hasLength(1));
  });

  test('label baru dalam cadangan dibuat saat impor', () async {
    final payload = jsonEncode({
      'app': 'tugasku',
      'version': 1,
      'labels': [
        {'name': 'Baru', 'colorValue': 0xFF123456},
      ],
      'tasks': [
        {'title': 'Tagih catatan', 'labels': ['Baru']},
      ],
    });
    final imported = await backupRepository.importJson(payload);
    expect(imported, 1);

    final labels = await db.select(db.labels).get();
    final baru = labels.where((label) => label.name == 'Baru').toList();
    expect(baru, hasLength(1));
    expect(baru.single.colorValue, 0xFF123456);
  });

  test('JSON asing ditolak dengan ArgumentError', () {
    expect(
      () => backupRepository.importJson('{"app":"lain"}'),
      throwsArgumentError,
    );
    expect(
      () => backupRepository.importJson('bukan json'),
      throwsFormatException,
    );
  });

  test('round-trip: ekspor → impor ke DB yang sama tidak boleh error',
      () async {
    await buatTugas(title: 'Kopi', dueDate: DateTime(2026, 10, 19, 8));
    final json = await backupRepository.exportJson();
    final imported = await backupRepository.importJson(json);
    expect(imported, 1);
    final tasks = await db.select(db.tasks).get();
    expect(tasks, hasLength(2));
  });
}
