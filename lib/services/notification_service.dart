import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../core/constants/app_strings.dart';

/// Layanan notifikasi pengingat (flutter_local_notifications + timezone).
///
/// Semua metode bersifat best-effort: jika platform tidak mendukung
/// (mis. saat test) atau izin belum diberikan, penjadwalan tidak
/// membuat aplikasi crash.
class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();
  static bool _initialized = false;

  final _plugin = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    try {
      tzdata.initializeTimeZones();
      // Lokasi perangkat Indonesia tetap dipakai; jam ditampilkan WIB.
      tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
    } catch (_) {
      // Fallback aman: lokal default timezone package.
    }

    try {
      const settings = InitializationSettings(
        android: AndroidInitializationSettings('mipmap/ic_launcher'),
      );
      await _plugin.initialize(settings);
    } catch (error) {
      // Contoh: dijalankan di lingkungan tanpa plugin (test). Abaikan.
      assert(
        () {
          // ignore: avoid_print
          print('flutter_local_notifications init gagal: $error');
          return true;
        }(),
      );
    }
  }

  /// Izin POST_NOTIFICATIONS diminta saat pengguna mengatur pengingat,
  /// bukan saat aplikasi dibuka (Kontrak Perilaku Bagian 8).
  Future<void> requestPermissionIfNeeded() async {
    try {
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    } catch (_) {
      // Tidak didukung pada platform ini.
    }
  }

  /// Menjadwalkan pengingat untuk satu tugas (id notifikasi = id tugas).
  Future<void> scheduleTaskReminder({
    required int taskId,
    required DateTime reminderAt,
  }) async {
    try {
      final when = tz.TZDateTime.from(reminderAt, tz.local);
      final now = tz.TZDateTime.now(tz.local);
      if (when.isBefore(now)) {
        await cancelTaskReminder(taskId);
        return;
      }
      await _plugin.zonedSchedule(
        taskId,
        AppStrings.appName,
        AppStrings.reminderNotificationBody,
        when,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'tugasku_reminders',
            'Pengingat Tugasku',
            channelDescription: 'Pengingat jatuh tempo tugas',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    } catch (_) {
      // Penjadwalan gagal (izin alarm, lingkungan test) - abaikan.
    }
  }

  /// Membatalkan pengingat tugas (hapus, selesai, atau diubah).
  Future<void> cancelTaskReminder(int taskId) async {
    try {
      await _plugin.cancel(taskId);
    } catch (_) {
      // Pembatalan gagal - abaikan.
    }
  }
}
