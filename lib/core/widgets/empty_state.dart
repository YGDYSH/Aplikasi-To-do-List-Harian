import 'package:flutter/material.dart';

import '../constants/app_strings.dart';
import '../theme/app_colors.dart';
import '../theme/text_styles.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, this.title, this.body, this.child});

  final String? title;
  final String? body;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.task_alt_rounded,
                size: 44,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title ?? AppStrings.tasksEmptyTitle,
              style: TextStyles.screenTitle,
              textAlign: TextAlign.center,
            ),
            if (body != null) ...[
              const SizedBox(height: 8),
              Text(
                body!,
                style: TextStyles.bodyMuted,
                textAlign: TextAlign.center,
              ),
            ],
            if (child != null) ...[const SizedBox(height: 16), child!],
          ],
        ),
      ),
    );
  }
}
