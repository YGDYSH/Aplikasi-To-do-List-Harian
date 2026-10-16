import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  static const primary = Color(0xFF5B4FE9);
  static const primaryLight = Color(0xFF8B83F5);
  static const background = Color(0xFFF6F5FF);
  static const surface = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF1E1B3A);
  static const textMuted = Color(0xFF8A88A3);
  static const danger = Color(0xFFE5484D);
  static const warning = Color(0xFFF5A524);
  static const success = Color(0xFF34C38F);

  static const labelPribadi = Color(0xFFF5A524);
  static const labelKerja = Color(0xFFF5A524);
  static const labelStudi = Color(0xFF8B83F5);
  static const labelBelajar = Color(0xFF8B83F5);
  static const labelOlahraga = Color(0xFF6B7280);
  static const labelKebiasaan = Color(0xFF34C38F);

  static const headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryLight, primary],
  );

  static const pageRadius = 16.0;
  static const headerRadius = 32.0;
  static const buttonRadius = 14.0;
  static const chipRadius = 999.0;

  static Color statusColor(int status) {
    switch (status) {
      case 2:
        return success;
      case 1:
        return warning;
      default:
        return danger;
    }
  }
}
