class TugaskuDateUtils {
  const TugaskuDateUtils._();

  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }

  static DateTime addDays(DateTime date, int days) {
    return date.add(Duration(days: days));
  }

  static DateTime tomorrow(DateTime date) {
    return addDays(startOfDay(date), 1);
  }

  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static bool isBeforeDay(DateTime a, DateTime b) {
    return startOfDay(a).isBefore(startOfDay(b));
  }

  /// Memulai minggu pada hari Senin.
  static DateTime startOfWeek(DateTime date) {
    final day = startOfDay(date);
    final weekday = day.weekday; // Senin = 1 ... Minggu = 7
    return addDays(day, -(weekday - 1));
  }

  /// Mengakhiri minggu pada hari Minggu (23:59:59).
  static DateTime endOfWeek(DateTime date) {
    return endOfDay(startOfWeek(date).add(const Duration(days: 6)));
  }

  static bool isWithin(DateTime date, DateTime start, DateTime end) {
    return !date.isBefore(start) && !date.isAfter(end);
  }
}
