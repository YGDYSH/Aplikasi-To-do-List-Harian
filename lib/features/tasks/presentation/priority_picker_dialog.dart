import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../providers/task_providers.dart';

/// Dialog pilihan prioritas tugas (Bagian 3.7 — baris ikon aksi).
/// Mengembalikan 0/1/2 atau null bila dibatalkan.
Future<int?> showPriorityPickerDialog(BuildContext context) {
  return showDialog<int>(
    context: context,
    builder: (dialogContext) => const _PriorityPickerDialog(),
  );
}

class _PriorityPickerDialog extends StatelessWidget {
  const _PriorityPickerDialog();

  static const _options = [0, 1, 2];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      title: Text(AppStrings.sortPriority, style: TextStyles.screenTitle),
      content: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final value in _options)
            _PriorityChip(value: value),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            AppStrings.cancelButton,
            style: TextStyles.body.copyWith(color: AppColors.textMuted),
          ),
        ),
      ],
    );
  }
}

class _PriorityChip extends StatelessWidget {
  const _PriorityChip({required this.value});

  final int value;

  Color get _color {
    switch (value) {
      case 2:
        return AppColors.danger;
      case 1:
        return AppColors.warning;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: _color.withValues(alpha: 0.12),
          borderRadius: const BorderRadius.all(
            Radius.circular(AppColors.chipRadius),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.flag_rounded, size: 16, color: _color),
            const SizedBox(width: 6),
            Text(priorityValueLabel(value), style: TextStyles.chip),
          ],
        ),
      ),
    );
  }
}
