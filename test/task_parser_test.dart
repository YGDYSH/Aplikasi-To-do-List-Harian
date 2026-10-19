import 'package:flutter_test/flutter_test.dart';

import 'package:aplikasi_to_do_list/core/utils/task_parser.dart';

void main() {
  // Waktu acuan tetap: Rabu, 14 Okt 2026 pukul 10.30 (lokal).
  final now = DateTime(2026, 10, 14, 10, 30);

  group('parseTaskPhrase: jam', () {
    test('jam penuh "15.00" / "07:30" terdeteksi & dihapus dari judul', () {
      final parsed = parseTaskPhrase('meeting 15.00', now: now);
      expect(parsed.title, 'Meeting');
      expect(parsed.hasTime, isTrue);
      expect(parsed.dueDate, DateTime(2026, 10, 14, 15, 0));

      final parsed2 = parseTaskPhrase('sikat gigi 07:30', now: now);
      expect(parsed2.title, 'Sikat gigi');
      expect(parsed2.hasTime, isTrue);
      expect(parsed2.dueDate, DateTime(2026, 10, 14, 7, 30));
    });

    test('"pukul 15" berarti jam 15.00', () {
      final parsed = parseTaskPhrase('jalan sore pukul 17', now: now);
      expect(parsed.title, 'Jalan sore');
      expect(parsed.dueDate, DateTime(2026, 10, 14, 17, 0));
    });

    test('jam tidak valid (25.00, 12.75) diabaikan', () {
      final parsed = parseTaskPhrase('rapat 25.00', now: now);
      expect(parsed.title, 'Rapat 25.00');
      expect(parsed.dueDate, isNull);

      final parsed2 = parseTaskPhrase('rapat 12.75', now: now);
      expect(parsed2.dueDate, isNull);
    });
  });

  group('parseTaskPhrase: hari', () {
    test('"besok" maju satu hari tanpa jam = 09.00', () {
      final parsed = parseTaskPhrase('belajar besok', now: now);
      expect(parsed.title, 'Belajar');
      expect(parsed.hasTime, isFalse);
      expect(parsed.dueDate, DateTime(2026, 10, 15, 9, 0));
    });

    test('"besok pukul 15.00" menggabungkan hari + jam', () {
      final parsed = parseTaskPhrase('belajar besok pukul 15.00', now: now);
      expect(parsed.title, 'Belajar');
      expect(parsed.dueDate, DateTime(2026, 10, 15, 15, 0));
      expect(parsed.hasTime, isTrue);
    });

    test('"lusa" maju dua hari', () {
      final parsed = parseTaskPhrase('gerai lusa', now: now);
      expect(parsed.dueDate, DateTime(2026, 10, 16, 9, 0));
    });

    test('nama hari maju ke minggu depan bila sudah lewat', () {
      // Rabu → sabtu = +3 hari (masih minggu ini).
      final parsed = parseTaskPhrase('tugas sabtu', now: now);
      expect(parsed.dueDate, DateTime(2026, 10, 17, 9, 0));

      // Rabu → senin = 2 hari minggu depan.
      final parsed2 = parseTaskPhrase('rapat senin', now: now);
      expect(parsed2.dueDate, DateTime(2026, 10, 19, 9, 0));
    });

    test('"hari ini" + jam tetap hari ini', () {
      final parsed = parseTaskPhrase('panggil ibu hari ini pukul 20', now: now);
      expect(parsed.dueDate, DateTime(2026, 10, 14, 20, 0));
    });

    test('tanpa token tanggal → tanpa dueDate', () {
      final parsed = parseTaskPhrase('beli susu', now: now);
      expect(parsed.title, 'Beli susu');
      expect(parsed.dueDate, isNull);
      expect(parsed.hasTime, isFalse);
    });
  });

  group('parseTaskPhrase: judul', () {
    test('input hanya berisi token waktu → judul = input asli', () {
      final parsed = parseTaskPhrase('besok pukul 15.00', now: now);
      expect(parsed.title, 'besok pukul 15.00');
      expect(parsed.dueDate, isNull);
    });

    test('input kosong berbahaya diabaikan aman', () {
      final parsed = parseTaskPhrase('   ', now: now);
      expect(parsed.title, '');
      expect(parsed.dueDate, isNull);
    });

    test('hasil judul dimulai huruf besar', () {
      final parsed = parseTaskPhrase('belajar MTK 15.00', now: now);
      expect(parsed.title, 'Belajar mtk');
    });
  });
}
