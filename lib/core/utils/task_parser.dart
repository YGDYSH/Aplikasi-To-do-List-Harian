/// Parser bahasa natural sederhana untuk Tambah Cepat (Tahap 5):
/// judul dengan frasa tanggal/jam ("besok pukul 15.00", "sabtu 07:30")
/// dipisah menjadi judul bersih + jatuh tempo.
library;

class ParsedTaskPhrase {
  const ParsedTaskPhrase({
    required this.title,
    this.dueDate,
    this.hasTime = false,
  });

  final String title;
  final DateTime? dueDate;

  /// true hanya bila jam ditemukan di frasa.
  final bool hasTime;
}

const _relativeTokens = <String, int>{
  'hari ini': 0,
  'besok': 1,
  'lusa': 2,
};

const _weekdayTokens = <String, int>{
  'senin': DateTime.monday,
  'selasa': DateTime.tuesday,
  'rabu': DateTime.wednesday,
  'kamis': DateTime.thursday,
  'jumat': DateTime.friday,
  'jum\'at': DateTime.friday,
  'sabtu': DateTime.saturday,
  'minggu': DateTime.sunday,
};

final _timeFullClock = RegExp(r'(\d{1,2})[.:](\d{2})');
final _timeHourOnly = RegExp(r'pukul\s+(\d{1,2})\b');
final _collapseSpaces = RegExp(r'\s+');

/// Mengurai frasa judul cepat.
///
/// - Jam: `15.00` / `07:30`, atau "pukul 15" (jam saja).
/// - Hari: "hari ini", "besok", "lusa", atau nama hari; nama hari yang
///   sudah lewat minggu ini jatuh ke minggu depan.
/// - Tanpa token hari bila ada jam → hari ini pada jam tersebut.
/// - Tanpa token hari & tanpa jam → tanpa tanggal.
/// - Bila seluruh input adalah token waktu, judul = input asli dan
///   tanpa data referensi.
ParsedTaskPhrase parseTaskPhrase(
  String raw, {
  required DateTime now,
}) {
  final original = raw.trim();
  String text = original.toLowerCase();
  final tokensToRemove = <String>{};

  // ---------- Jam ----------
  int? hour;
  int? minute;
  final fullClock = _timeFullClock.firstMatch(text);
  if (fullClock != null) {
    final maybeHour = int.tryParse(fullClock.group(1)!);
    final maybeMinute = int.tryParse(fullClock.group(2)!);
    if (maybeHour != null &&
        maybeMinute != null &&
        maybeHour >= 0 &&
        maybeHour <= 23 &&
        maybeMinute >= 0 &&
        maybeMinute <= 59) {
      hour = maybeHour;
      minute = maybeMinute;
      tokensToRemove.add(fullClock.group(0)!);
      // "pukul 15.00": buang kata "pukul" yang mengikuti jam penuh.
      final before = text.substring(0, fullClock.start).trimRight();
      if (before.endsWith('pukul')) {
        tokensToRemove.add('pukul');
      }
    }
  } else {
    final hourOnly = _timeHourOnly.firstMatch(text);
    if (hourOnly != null) {
      final maybeHour = int.tryParse(hourOnly.group(1)!);
      if (maybeHour != null && maybeHour >= 0 && maybeHour <= 23) {
        hour = maybeHour;
        minute = 0;
        tokensToRemove.add(hourOnly.group(0)!);
      }
    }
  }

  // ---------- Hari ----------
  int? daysAhead;
  for (final entry in _relativeTokens.entries) {
    if (!text.contains(entry.key)) continue;
    daysAhead = entry.value;
    tokensToRemove.add(entry.key);
    break;
  }
  if (daysAhead == null) {
    for (final entry in _weekdayTokens.entries) {
      if (!text.contains(entry.key)) continue;
      daysAhead = (entry.value - now.weekday + 7) % 7;
      tokensToRemove.add(entry.key);
      break;
    }
  }
  if (daysAhead == null && hour != null) {
    // "rapat 15.00" → hari ini pada jam tersebut.
    daysAhead = 0;
  }

  for (final token in tokensToRemove) {
    text = text.replaceFirst(token, ' ');
  }

  final cleaned = text.replaceAll(_collapseSpaces, ' ').trim();
  if (cleaned.isEmpty) {
    return ParsedTaskPhrase(title: original);
  }

  DateTime? dueDate;
  final hasTime = hour != null && minute != null;
  if (daysAhead != null) {
    final base = DateTime(
      now.year,
      now.month,
      now.day,
    ).add(Duration(days: daysAhead));
    dueDate = hasTime
        ? DateTime(base.year, base.month, base.day, hour, minute)
        : DateTime(base.year, base.month, base.day, 9, 0);
  }

  final title = cleaned.length == 1
      ? cleaned.toUpperCase()
      : cleaned[0].toUpperCase() + cleaned.substring(1);

  return ParsedTaskPhrase(
    title: title,
    dueDate: dueDate,
    hasTime: hasTime,
  );
}
