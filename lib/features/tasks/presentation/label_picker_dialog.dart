import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../data/db/app_database.dart';

Future<Set<int>?> showLabelPickerDialog(
  BuildContext context, {
  required List<Label> labels,
  required Set<int> selected,
}) {
  return showDialog<Set<int>>(
    context: context,
    builder: (_) => _LabelPickerDialog(labels: labels, initial: selected),
  );
}

class _LabelPickerDialog extends StatefulWidget {
  const _LabelPickerDialog({required this.labels, required this.initial});

  final List<Label> labels;
  final Set<int> initial;

  @override
  State<_LabelPickerDialog> createState() => _LabelPickerDialogState();
}

class _LabelPickerDialogState extends State<_LabelPickerDialog> {
  late final Set<int> _selected;

  @override
  void initState() {
    super.initState();
    _selected = Set<int>.of(widget.initial);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(AppColors.pageRadius)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppStrings.selectLabelsTitle, style: TextStyles.screenTitle),
            const SizedBox(height: 12),
            if (widget.labels.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child:
                    Text(AppStrings.noLabelsYet, style: TextStyles.bodyMuted),
              )
            else
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      for (final label in widget.labels)
                        CheckboxListTile(
                          value: _selected.contains(label.id),
                          controlAffinity: ListTileControlAffinity.leading,
                          activeColor: AppColors.primary,
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          title: Text(label.name, style: TextStyles.body),
                          onChanged: (checked) => setState(() {
                            if (checked == true) {
                              _selected.add(label.id);
                            } else {
                              _selected.remove(label.id);
                            }
                          }),
                        ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(null),
                  child: Text(
                    AppStrings.cancelButton,
                    style:
                        TextStyles.body.copyWith(color: AppColors.textMuted),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(_selected),
                  child: Text(
                    AppStrings.saveButton,
                    style: TextStyles.body.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
