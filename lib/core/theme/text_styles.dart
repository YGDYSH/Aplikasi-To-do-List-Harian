import 'package:flutter/material.dart';

import '../constants/app_strings.dart';
import 'app_colors.dart';

class TextStyles {
  const TextStyles._();

  static const String _family = AppStrings.fontPrimary;

  static const headerTitle = TextStyle(
    fontFamily: _family,
    fontSize: 28,
    height: 1.2,
    fontWeight: FontWeight.w800,
    color: AppColors.surface,
  );

  static const headerCaption = TextStyle(
    fontFamily: _family,
    fontSize: 13,
    height: 1.3,
    fontWeight: FontWeight.w500,
    color: AppColors.surface,
  );

  static const displayTitle = TextStyle(
    fontFamily: _family,
    fontSize: 32,
    height: 1.2,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
  );

  static const screenTitle = TextStyle(
    fontFamily: _family,
    fontSize: 24,
    height: 1.25,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
  );

  static const sectionTitle = TextStyle(
    fontFamily: _family,
    fontSize: 12,
    height: 1.2,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.8,
    color: AppColors.textMuted,
  );

  static const cardTitle = TextStyle(
    fontFamily: _family,
    fontSize: 16,
    height: 1.3,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const body = TextStyle(
    fontFamily: _family,
    fontSize: 14,
    height: 1.45,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static const bodyMuted = TextStyle(
    fontFamily: _family,
    fontSize: 14,
    height: 1.45,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
  );

  static const caption = TextStyle(
    fontFamily: _family,
    fontSize: 12,
    height: 1.3,
    fontWeight: FontWeight.w500,
    color: AppColors.textMuted,
  );

  static const chip = TextStyle(
    fontFamily: _family,
    fontSize: 12,
    height: 1.2,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const button = TextStyle(
    fontFamily: _family,
    fontSize: 16,
    height: 1.2,
    fontWeight: FontWeight.w700,
    color: AppColors.surface,
  );

  static const navLabel = TextStyle(
    fontFamily: _family,
    fontSize: 11,
    height: 1.2,
    fontWeight: FontWeight.w600,
    color: AppColors.textMuted,
  );

  static const navLabelActive = TextStyle(
    fontFamily: _family,
    fontSize: 11,
    height: 1.2,
    fontWeight: FontWeight.w700,
    color: AppColors.primary,
  );

  static const inputHint = TextStyle(
    fontFamily: _family,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
  );

  static const snackBar = TextStyle(
    fontFamily: _family,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.surface,
  );
}
