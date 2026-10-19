import '../../data/db/app_database.dart';
import 'date_utils.dart';

/// Statistik satu hari (Bagian 3.6 Halaman 11):
/// - `completedCount` = jumlah tugas selesai pada hari itu.
/// - `totalCount` = jumlah total tugas pada hari itu.
/// - Produktivitas = selesai / total tugas hari itu (persen).
class DayStats {
  const DayStats({
    required this.completedCount,
    required this.totalCount,
  });

  final int completedCount;
  final int totalCount;

  int get productivityPercent {
    if (totalCount == 0) return 0;
    return (completedCount * 100 / totalCount).round();
  }
}

/// Fungsi murni: menghitung statistik [DayStats] untuk [day] (waktu lokal).
/// dueDate tersimpan UTC, sehingga dibandingkan sebagai waktu lokal.
DayStats computeDayStats(List<Task> tasks, {required DateTime day}) {
  var total = 0;
  var completed = 0;
  for (final task in tasks) {
    final due = task.dueDate;
    if (due == null) continue;
    if (!TugaskuDateUtils.isSameDay(due.toLocal(), day)) continue;
    total++;
    if (task.isDone) completed++;
  }
  return DayStats(completedCount: completed, totalCount: total);
}

/// Fungsi murni: daftar tugas yang jatuh tempo pada [day] (waktu lokal).
List<Task> tasksDueOnDay(List<Task> tasks, {required DateTime day}) {
  return [
    for (final task in tasks)
      if (task.dueDate != null &&
          TugaskuDateUtils.isSameDay(task.dueDate!.toLocal(), day))
        task,
  ];
}
