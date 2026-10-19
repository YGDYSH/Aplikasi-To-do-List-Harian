import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileController extends ChangeNotifier {
  ProfileController({required this.prefs})
      : userName = prefs.getString(_keyName) ?? '',
        onboardingDone = prefs.getBool(_keyOnboarding) ?? false;

  static const _keyOnboarding = 'onboarding_done';
  static const _keyName = 'user_name';

  final SharedPreferences prefs;

  String userName;
  bool onboardingDone;

  bool get isReady => onboardingDone && userName.isNotEmpty;

  void setUserName(String name) {
    final trimmed = name.trim();
    userName = trimmed;
    prefs.setString(_keyName, trimmed);
    notifyListeners();
  }

  void completeOnboarding() {
    onboardingDone = true;
    prefs.setBool(_keyOnboarding, true);
    notifyListeners();
  }
}

final profileControllerProvider = ChangeNotifierProvider<ProfileController>(
  (ref) {
    throw UnimplementedError(
      'profileControllerProvider harus di-override di main.dart',
    );
  },
);
