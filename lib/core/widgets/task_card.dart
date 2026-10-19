import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../constants/app_strings.dart';
import '../theme/app_colors.dart';
import '../theme/text_styles.dart';
import 'label_chip.dart';

class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key,
    required this.title,
    required this.dateText,
    required this.isDone,
    this.isOverdue = false,
    this.labels = const [],
    this.repeatText,
    this.onToggleDone,
    this.onOpenDetails,
  });

  final String title;
  final String? dateText;
  final bool isDone;
  final bool isOverdue;
  final List<LabelChipData> labels;

  /// Keterangan berulang kecil (Tahap 5 — Bagian 3.4).
  final String? repeatText;
  final VoidCallback? onToggleDone;
  final VoidCallback? onOpenDetails;

  @override
  Widget build(BuildContext context) {
    final titleStyle = isDone
        ? TextStyles.cardTitle.copyWith(
            color: AppColors.textMuted,
            decoration: TextDecoration.lineThrough,
            decorationColor: AppColors.textMuted,
          )
        : TextStyles.cardTitle;

    final dateColor = isOverdue ? AppColors.danger : AppColors.textMuted;

    return Material(
      color: AppColors.surface,
      borderRadius: const BorderRadius.all(Radius.circular(AppColors.pageRadius)),
      child: InkWell(
        onTap: onOpenDetails,
        borderRadius: const BorderRadius.all(Radius.circular(AppColors.pageRadius)),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              _CheckCircle(isDone: isDone, onTap: onToggleDone),
              const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: titleStyle, maxLines: 2, overflow: TextOverflow.ellipsis),
                      if (dateText != null && dateText!.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(dateText!, style: TextStyles.caption.copyWith(color: dateColor)),
                      ],
                      if (repeatText != null && repeatText!.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.repeat_rounded,
                              size: 12,
                              color: AppColors.textMuted,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              repeatText!,
                              style: TextStyles.caption,
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (final labelData in labels.take(2))
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: LabelChip(
                        name: labelData.name,
                        colorValue: labelData.colorValue,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LabelChipData {
  const LabelChipData({required this.id, required this.name, required this.colorValue});

  final int id;
  final String name;
  final int colorValue;
}

class _CheckCircle extends StatelessWidget {
  const _CheckCircle({required this.isDone, this.onTap});

  final bool isDone;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDone ? AppColors.primary : Colors.transparent,
          border: Border.all(
            color: isDone ? AppColors.primary : AppColors.primaryLight,
            width: 2,
          ),
        ),
        child: isDone
            ? const Icon(Icons.check_rounded, size: 16, color: AppColors.surface)
            : null,
      ),
    );
  }
}

String formatTaskDate(DateTime dueDate, {required DateTime now}) {
  final local = dueDate.toLocal();
  if (_isSameDay(local, now)) {
    return AppStrings.todayGreeting;
  }
  final tomorrow = now.add(const Duration(days: 1));
  if (_isSameDay(local, tomorrow)) {
    return AppStrings.groupTomorrow;
  }
  return DateFormat('d MMM', AppStrings.localeId).format(local);
}

bool _isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}
