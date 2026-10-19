import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:aplikasi_to_do_list/app.dart';
import 'package:aplikasi_to_do_list/data/db/app_database.dart';
import 'package:aplikasi_to_do_list/data/providers.dart';
import 'package:aplikasi_to_do_list/features/profile/providers/profile_provider.dart';

void main() {
  testWidgets('alur onboarding: tombol lanjut membuka layar profil',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(const {});
    final prefs = await SharedPreferences.getInstance();
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          profileControllerProvider.overrideWith((ref) => ProfileController(prefs: prefs)),
        ],
        child: const TugaskuApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Selesaikan Tugasmu'), findsOneWidget);
    expect(find.text('Ayo Mulai!'), findsNothing);

    await tester.tap(find.byIcon(Icons.arrow_forward_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Ayo Mulai!'), findsOneWidget);
  });

  testWidgets('menampilkan layar daftar, grup, dan bottom bar dengan data',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(const {
      'onboarding_done': true,
      'user_name': 'Adi',
    });
    final prefs = await SharedPreferences.getInstance();
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        profileControllerProvider.overrideWith((ref) => ProfileController(prefs: prefs)),
      ],
    );
    addTearDown(container.dispose);

    await container
        .read(taskRepositoryProvider)
        .insertTask(title: 'Belajar Gamma', dueDate: DateTime(2026, 10, 19));

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TugaskuApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Tugasku'), findsOneWidget);
    expect(find.text('Belajar Gamma'), findsOneWidget);
    expect(find.text('HARI INI'), findsOneWidget);
    expect(find.text('1 TUGAS'), findsOneWidget);
    expect(find.text('BELUM ADA TUGAS'), findsNothing);
    expect(find.byType(FloatingActionButton), findsOneWidget);

    final taskId =
        (await container.read(taskRepositoryProvider).getTasks()).first.id;
    await container
        .read(taskRepositoryProvider)
        .setTaskDone(taskId, true);
    await tester.pumpAndSettle();

    final task =
        (await db.select(db.tasks).get()).singleWhere((t) => t.isDone);
    expect(task.isDone, isTrue);
    expect(task.status, 2);
  });

  testWidgets('menampilkan layar kalender lewat tab kalender',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(const {
      'onboarding_done': true,
      'user_name': 'Adi',
    });
    final prefs = await SharedPreferences.getInstance();
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        profileControllerProvider.overrideWith((ref) => ProfileController(prefs: prefs)),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TugaskuApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Kalender'));
    await tester.pumpAndSettle();

    expect(find.text('Jadwalmu akan muncul di sini'), findsOneWidget);
  });
}

