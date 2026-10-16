import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aplikasi_to_do_list/app.dart';

void main() {
  testWidgets('menampilkan header gradien dan bottom bar 2 tab',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: TugaskuApp()));
    await tester.pumpAndSettle();

    expect(find.text('Daftar'), findsOneWidget);
    expect(find.text('Kalender'), findsOneWidget);
    expect(find.text('Tugasku'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);

    await tester.tap(find.text('Kalender'));
    await tester.pumpAndSettle();

    expect(find.text('Jadwalmu akan muncul di sini'), findsOneWidget);
    expect(find.text('Kalender'), findsNWidgets(2));
  });
}
