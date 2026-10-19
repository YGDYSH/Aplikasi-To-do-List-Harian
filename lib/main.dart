import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/constants/app_strings.dart';
import 'data/db/app_database.dart';
import 'data/providers.dart';
import 'features/profile/providers/profile_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting(AppStrings.localeId);
  final prefs = await SharedPreferences.getInstance();
  final database = AppDatabase();

  runApp(
    ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(database),
        profileControllerProvider.overrideWith(
          (ref) => ProfileController(prefs: prefs),
        ),
      ],
      child: const TugaskuApp(),
    ),
  );
}
