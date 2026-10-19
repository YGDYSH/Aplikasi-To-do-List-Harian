import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../providers/task_providers.dart';

/// Dialog modal "Urutkan" (Bagian 3.5): 4 opsi radio, latar diburamkan,
/// pilihan tersimpan otomatis lewat [sortOptionProvider].
Future<void> showSortDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    barrierColor: AppColors.textPrimary.withValues(alpha: 0.45),
    builder: (_) => const _SortDialogRoot(),
  );
}

class _SortDialogRoot extends StatelessWidget {
  const _SortDialogRoot();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: const SortDialog(),
      ),
    );
  }
}

class SortDialog extends ConsumerWidget {
  const SortDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(sortOptionProvider);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 18, 12, 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.all(
            Radius.circular(AppColors.pageRadius),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    AppStrings.sortTitle,
                    style: TextStyles.screenTitle.copyWith(fontSize: 20),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.close_rounded,
                    size: 20,
                    color: AppColors.textMuted,
                  ),
                  tooltip: AppStrings.cancelButton,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 6),
            RadioGroup<SortOption>(
              groupValue: current,
              onChanged: (value) {
                if (value != null) {
                  ref.read(sortOptionProvider.notifier).select(value);
                }
              },
              child: Column(
                children: [
                  for (final option in SortOption.values)
                    RadioListTile<SortOption>(
                      value: option,
                      selected: option == current,
                      activeColor: AppColors.primary,
                      title: Text(sortOptionLabel(option), style: TextStyles.body),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
