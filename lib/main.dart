import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/constants/app_strings.dart';
import 'data/db/app_database.dart';
import 'data/providers.dart';
import 'features/profile/providers/profile_provider.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting(AppStrings.localeId);
  final prefs = await SharedPreferences.getInstance();
  final database = AppDatabase();

  // Notifikasi pengingat + timezone (WIB) disiapkan di awal best-effort.
  await NotificationService.instance.initialize();

  runApp(
    ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(database),
        sharedPrefsProvider.overrideWithValue(prefs),
        profileControllerProvider.overrideWith(
          (ref) => ProfileController(prefs: prefs),
        ),
      ],
      child: const TugaskuApp(),
    ),
  );
}
