import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/utils/repeat_rule.dart';

/// Dialog pilihan pengulangan tugas (Tahap 5).
/// Mengembalikan:
/// - null → dibatalkan
/// - ''   → tidak berulang
/// - 'daily' | 'two_days' | 'weekly'
Future<String?> showRepeatPickerDialog(BuildContext context) {
  const options = [
    null,
    RepeatRuleKey.daily,
    RepeatRuleKey.twoDays,
    RepeatRuleKey.weekly,
  ];
  return showDialog<String>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: AppColors.surface,
      title: Text(AppStrings.repeatIconTooltip, style: TextStyles.screenTitle),
      content: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final option in options)
            _RepeatChip(option: option),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: Text(
            AppStrings.cancelButton,
            style: TextStyles.body.copyWith(color: AppColors.textMuted),
          ),
        ),
      ],
    ),
  );
}

class _RepeatChip extends StatelessWidget {
  const _RepeatChip({required this.option});

  final RepeatRuleKey? option;

  @override
  Widget build(BuildContext context) {
    final RepeatRuleKey? current = option;
    final String storageValue;
    final String label;
    if (current == null) {
      storageValue = '';
      label = repeatRuleLabel(null);
    } else {
      storageValue = repeatRuleStorageValue(current);
      label = repeatRuleLabel(storageValue);
    }
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(storageValue),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.12),
          borderRadius: const BorderRadius.all(
            Radius.circular(AppColors.chipRadius),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.repeat_rounded,
              size: 16,
              color: AppColors.primary,
            ),
            const SizedBox(width: 6),
            Text(label, style: TextStyles.chip),
          ],
        ),
      ),
    );
  }
}
