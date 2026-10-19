import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import 'package:aplikasi_to_do_list/data/db/app_database.dart';
import 'package:aplikasi_to_do_list/data/repositories/label_repository.dart';
import 'package:aplikasi_to_do_list/data/repositories/task_repository.dart';

void main() {
  late AppDatabase db;
  late TaskRepository taskRepository;
  late LabelRepository labelRepository;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    taskRepository = TaskRepository(db);
    labelRepository = LabelRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> pump() => Future<void>.delayed(const Duration(milliseconds: 50));

  test('seed pertama kali berisi 5 label awal', () async {
    final labels = await labelRepository.getLabels();

    expect(labels, hasLength(5));
    expect(
      labels.map((label) => label.name),
      unorderedEquals(['Belajar', 'Olahraga', 'Kerja', 'Pribadi', 'Kebiasaan']),
    );
  });

  test('menyimpan dan membaca tugas', () async {
    final id = await taskRepository.insertTask(
      title: '  Belajar Flutter  ',
      note: 'Bab database',
      dueDate: DateTime.utc(2026, 10, 19, 6),
      hasTime: true,
      priority: 2,
    );

    final task = await taskRepository.getTask(id);

    expect(task?.title, 'Belajar Flutter');
    expect(task?.note, 'Bab database');
    expect(task?.hasTime, true);
    expect(task?.priority, 2);
    expect(task?.status, 0);
    expect(task?.isDone, false);
    expect(task?.dueDate, DateTime.utc(2026, 10, 19, 6));
    expect(task?.createdAt, isNotNull);
    expect(task?.completedAt, isNull);
  });

  test('judul kosong tidak boleh disimpan', () async {
    await expectLater(
      taskRepository.insertTask(title: '   '),
      throwsArgumentError,
    );
  });

  test('memperbarui tugas', () async {
    final id = await taskRepository.insertTask(title: 'Lama');

    await taskRepository.updateTask(
      id,
      const TasksCompanion(
        title: Value('Baru'),
        note: Value('Catatan'),
        priority: Value(1),
      ),
    );

    final task = await taskRepository.getTask(id);
    expect(task?.title, 'Baru');
    expect(task?.note, 'Catatan');
    expect(task?.priority, 1);
    expect(task?.hasTime, false);
    expect(task?.dueDate, isNull);
  });

  test('judul kosong saat pembaruan ditolak', () async {
    final id = await taskRepository.insertTask(title: 'Lama');

    await expectLater(
      taskRepository.updateTask(id, const TasksCompanion(title: Value(' '))),
      throwsArgumentError,
    );
  });

  test('centang tugas mengubah status dan waktu selesai', () async {
    final id = await taskRepository.insertTask(title: 'Tugas');

    await taskRepository.setTaskDone(id, true);
    var task = await taskRepository.getTask(id);
    expect(task?.isDone, true);
    expect(task?.status, 2);
    expect(task?.completedAt, isNotNull);

    await taskRepository.setTaskDone(id, false);
    task = await taskRepository.getTask(id);
    expect(task?.isDone, false);
    expect(task?.status, 0);
    expect(task?.completedAt, isNull);
  });

  test('menghapus tugas', () async {
    final id = await taskRepository.insertTask(title: 'Hapus aku');

    await taskRepository.deleteTask(id);

    expect(await taskRepository.getTask(id), isNull);
  });

  test('menghapus tugas ikut menghapus tautan label terkait', () async {
    final id = await taskRepository.insertTask(title: 'Tersambung');
    final labelIds = (await labelRepository.getLabels()).map((l) => l.id).toList();

    await taskRepository.setLabelsForTask(id, [labelIds.first]);
    expect(await db.select(db.taskLabels).get(), hasLength(1));

    await taskRepository.deleteTask(id);
    expect(await db.select(db.taskLabels).get(), isEmpty);
  });

  test('mengganti label tugas', () async {
    final id = await taskRepository.insertTask(title: 'Tugas');
    final labels = await labelRepository.getLabels();
    final firstLabelId = labels.first.id;
    final secondLabelId = labels[1].id;
    final thirdLabelId = labels[2].id;

    await taskRepository.setLabelsForTask(id, [firstLabelId, secondLabelId]);
    var attached = await taskRepository.watchLabelsOfTask(id).first;
    expect(attached.map((label) => label.id), unorderedEquals([firstLabelId, secondLabelId]));

    await taskRepository.setLabelsForTask(id, [thirdLabelId]);
    attached = await taskRepository.watchLabelsOfTask(id).first;
    expect(attached.map((label) => label.id), [thirdLabelId]);
  });

  test('stream tugas menerima data terbaru', () async {
    final emissions = <List<Task>>[];
    final subscription = taskRepository.watchTasks().listen(emissions.add);
    await pump();

    final id = await taskRepository.insertTask(title: 'Baru');
    await pump();
    await taskRepository.setTaskDone(id, true);
    await pump();
    await taskRepository.deleteTask(id);
    await pump();

    expect(emissions, [
      isEmpty,
      hasLength(1),
      hasLength(1),
      isEmpty,
    ]);
    expect(emissions[1].single.title, 'Baru');
    expect(emissions[2].single.isDone, true);

    await subscription.cancel();
  });

  test('pencarian tidak peka huruf besar dan kecil', () async {
    await taskRepository.insertTask(title: 'Belajar Flutter', note: 'bab database');
    await taskRepository.insertTask(title: 'Olahraga pagi');

    var results = await taskRepository.watchTasks(query: 'belajar').first;
    expect(results.map((task) => task.title), ['Belajar Flutter']);

    results = await taskRepository.watchTasks(query: 'BAB').first;
    expect(results.map((task) => task.title), ['Belajar Flutter']);

    results = await taskRepository.watchTasks().first;
    expect(results, hasLength(2));
  });

  test('stream label memperbarui hasil', () async {
    final emissions = <List<Label>>[];
    final subscription = labelRepository.watchLabels().listen(emissions.add);
    await pump();

    await labelRepository.createLabel(name: 'Kuliah', colorValue: 0xFF112233);
    await pump();

    expect(emissions, [hasLength(5), hasLength(6)]);
    expect(emissions.last.last.name, 'Kuliah');

    await subscription.cancel();
  });

  test('nama label kosong ditolak', () async {
    await expectLater(
      labelRepository.createLabel(name: '   ', colorValue: 0xFF112233),
      throwsArgumentError,
    );
  });

  test('label dengan nama sama ditolak', () async {
    await labelRepository.createLabel(name: 'Kuliah', colorValue: 0xFF112233);

    await expectLater(
      labelRepository.createLabel(name: ' kuliah ', colorValue: 0xFF112233),
      throwsStateError,
    );
  });

  test('memperbarui dan menghapus label', () async {
    final id = await labelRepository.createLabel(name: 'Kuliah', colorValue: 0xFF112233);

    await labelRepository.updateLabel(id, name: 'Kuliah Baru');
    await labelRepository.updateLabel(id, colorValue: 0xFF445566);

    var label = await labelRepository.getLabel(id);
    expect(label?.name, 'Kuliah Baru');
    expect(label?.colorValue, 0xFF445566);

    await labelRepository.deleteLabel(id);
    expect(await labelRepository.getLabel(id), isNull);
  });

  test('data tetap ada setelah aplikasi dibuka ulang', () async {
    final workspace = await Directory.systemTemp.createTemp('tugasku_test');
    try {
      final file = File(p.join(workspace.path, 'tugasku.db'));
      final firstDatabase = AppDatabase.forTesting(NativeDatabase(file));
      final firstTasks = TaskRepository(firstDatabase);
      final id = await firstTasks.insertTask(title: 'Tugas persisten');
      await firstDatabase.close();

      final secondDatabase = AppDatabase.forTesting(NativeDatabase(file));
      final secondTasks = TaskRepository(secondDatabase);
      final loaded = await secondTasks.getTask(id);
      expect(loaded?.title, 'Tugas persisten');
      await secondDatabase.close();
    } finally {
      await workspace.delete(recursive: true);
    }
  });
}
