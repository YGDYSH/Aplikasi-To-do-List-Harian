import 'package:flutter/material.dart';

import 'package:aplikasi_to_do_list/core/constants/app_strings.dart';
import 'package:aplikasi_to_do_list/core/theme/app_colors.dart';
import 'package:aplikasi_to_do_list/core/theme/text_styles.dart';
import 'package:aplikasi_to_do_list/core/widgets/gradient_header.dart';

class TaskListScreen extends StatelessWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GradientHeader(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.todayGreeting,
                style: TextStyles.headerCaption.copyWith(
                  color: AppColors.surface.withValues(alpha: 0.85),
                ),
              ),
              const SizedBox(height: 4),
              Text(AppStrings.tasksTitle, style: TextStyles.headerTitle),
            ],
          ),
        ),
        Expanded(
          child: Center(
            child: Text(
              AppStrings.tasksPlaceholder,
              style: TextStyles.bodyMuted,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}
