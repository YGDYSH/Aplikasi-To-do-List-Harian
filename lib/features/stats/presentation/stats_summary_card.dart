import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../data/db/app_database.dart';
import '../../tasks/providers/task_providers.dart';
import '../providers/stats_providers.dart';

/// Kartu statistik untuk empty state "semua selesai" (Bagian 3.6
/// Halaman 11): TERSELESAIKAN, PRODUKTIVITAS, dan chip Kategori Tugas.
class StatsSummaryCard extends ConsumerWidget {
  const StatsSummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(dayStatsProvider);
    final labels = ref.watch(labelsStreamProvider).value ?? const <Label>[];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.all(
          Radius.circular(AppColors.pageRadius),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 88,
              height: 88,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.headerGradient,
              ),
              child: const Icon(
                Icons.emoji_events_rounded,
                size: 40,
                color: AppColors.surface,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            AppStrings.statsYayTitle,
            style: TextStyles.cardTitle.copyWith(fontSize: 15),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            AppStrings.statsYaySubtitle,
            style: TextStyles.bodyMuted,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _StatColumn(
                  label: AppStrings.statsCompletedLabel,
                  value: AppStrings.statsCompletedValue(stats.completedCount),
                ),
              ),
              Expanded(
                child: _StatColumn(
                  label: AppStrings.statsProductivityLabel,
                  value: AppStrings.statsProductivityValue(
                    stats.productivityPercent,
                  ),
                ),
              ),
            ],
          ),
          if (labels.isNotEmpty) ...[
            const SizedBox(height: 18),
            Text(
              AppStrings.statsCategorySection.toUpperCase(),
              style: TextStyles.sectionTitle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final label in labels)
                  _CategoryDotChip(
                    name: label.name,
                    colorValue: label.colorValue,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyles.caption.copyWith(
            color: AppColors.textMuted,
            fontSize: 11,
            letterSpacing: 0.8,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyles.cardTitle.copyWith(color: AppColors.primary),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _CategoryDotChip extends StatelessWidget {
  const _CategoryDotChip({required this.name, required this.colorValue});

  final String name;
  final int colorValue;

  @override
  Widget build(BuildContext context) {
    final color = Color(colorValue);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: const BorderRadius.all(
          Radius.circular(AppColors.chipRadius),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(name, style: TextStyles.chip),
        ],
      ),
    );
  }
}
