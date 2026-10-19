import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/text_styles.dart';

class LabelChip extends StatelessWidget {
  const LabelChip({super.key, required this.name, required this.colorValue});

  final String name;
  final int colorValue;

  @override
  Widget build(BuildContext context) {
    final color = Color(colorValue);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
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
          Text(
            name,
            style: TextStyles.chip.copyWith(fontSize: 11),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
