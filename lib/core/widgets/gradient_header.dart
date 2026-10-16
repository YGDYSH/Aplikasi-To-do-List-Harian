import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class GradientHeader extends StatelessWidget {
  const GradientHeader({
    super.key,
    required this.child,
    this.bottomRadius = AppColors.headerRadius,
    this.padding = const EdgeInsets.fromLTRB(20, 16, 20, 28),
  });

  final Widget child;
  final double bottomRadius;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(bottom: Radius.circular(bottomRadius)),
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.headerGradient),
        child: Stack(
          children: [
            Positioned(
              right: -48,
              top: -56,
              child: _DecorationCircle(
                size: 170,
                color: AppColors.surface.withValues(alpha: 0.10),
              ),
            ),
            Positioned(
              left: -60,
              bottom: -90,
              child: _DecorationCircle(
                size: 190,
                color: AppColors.surface.withValues(alpha: 0.07),
              ),
            ),
            Positioned(
              right: 96,
              top: 74,
              child: _DecorationCircle(
                size: 14,
                color: AppColors.surface.withValues(alpha: 0.35),
              ),
            ),
            SafeArea(
              bottom: false,
              child: Padding(padding: padding, child: child),
            ),
          ],
        ),
      ),
    );
  }
}

class _DecorationCircle extends StatelessWidget {
  const _DecorationCircle({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
