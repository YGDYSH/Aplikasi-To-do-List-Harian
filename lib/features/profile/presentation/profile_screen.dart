import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:aplikasi_to_do_list/core/constants/app_strings.dart';
import 'package:aplikasi_to_do_list/core/router/app_router.dart';
import 'package:aplikasi_to_do_list/core/theme/app_colors.dart';
import 'package:aplikasi_to_do_list/core/theme/text_styles.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 40,
                  color: AppColors.surface,
                ),
              ),
              const Spacer(),
              Text(AppStrings.profileTitle, style: TextStyles.displayTitle),
              const SizedBox(height: 8),
              Text(AppStrings.profileSubtitle, style: TextStyles.bodyMuted),
              const SizedBox(height: 28),
              Text(
                AppStrings.nameLabel,
                style: TextStyles.sectionTitle,
              ),
              const SizedBox(height: 10),
              const TextField(
                decoration: InputDecoration(hintText: AppStrings.nameHint),
              ),
              const SizedBox(height: 16),
              Text(AppStrings.profilePage, style: TextStyles.caption),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.go(AppRoutes.tasks),
                  child: const Text(AppStrings.startButton),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
