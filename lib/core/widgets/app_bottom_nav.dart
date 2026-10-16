import 'package:flutter/material.dart';

import '../constants/app_strings.dart';
import '../theme/app_colors.dart';
import '../theme/text_styles.dart';

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onIndexChanged,
    required this.onAddPressed,
  });

  final int currentIndex;
  final ValueChanged<int> onIndexChanged;
  final VoidCallback onAddPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Material(
        color: AppColors.surface,
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 66,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: Row(
                    children: [
                      Expanded(
                        child: _NavItem(
                          icon: Icons.check_circle_outline_rounded,
                          label: AppStrings.tabTasks,
                          selected: currentIndex == 0,
                          onTap: () => onIndexChanged(0),
                        ),
                      ),
                      const SizedBox(width: 96),
                      Expanded(
                        child: _NavItem(
                          icon: Icons.calendar_month_rounded,
                          label: AppStrings.tabCalendar,
                          selected: currentIndex == 1,
                          onTap: () => onIndexChanged(1),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  top: -28,
                  child: Center(
                    child: SizedBox(
                      width: 56,
                      height: 56,
                      child: FloatingActionButton(
                        onPressed: onAddPressed,
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.surface,
                        elevation: 8,
                        shape: const CircleBorder(),
                        child: const Icon(Icons.edit_rounded, size: 24),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 24,
            color: selected ? AppColors.primary : AppColors.textMuted,
          ),
          const SizedBox(height: 4),
          Text(label, style: selected ? TextStyles.navLabelActive : TextStyles.navLabel),
        ],
      ),
    );
  }
}
