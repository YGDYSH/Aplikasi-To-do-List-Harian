import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:aplikasi_to_do_list/core/theme/app_colors.dart';
import 'package:aplikasi_to_do_list/core/widgets/app_bottom_nav.dart';
import 'package:aplikasi_to_do_list/features/calendar/presentation/calendar_screen.dart';
import 'package:aplikasi_to_do_list/features/onboarding/presentation/onboarding_screen.dart';
import 'package:aplikasi_to_do_list/features/profile/presentation/profile_screen.dart';
import 'package:aplikasi_to_do_list/features/tasks/presentation/task_list_screen.dart';

class AppRoutes {
  const AppRoutes._();

  static const onboarding = '/';
  static const profile = '/profile';
  static const tasks = '/home/tasks';
  static const calendar = '/home/calendar';
}

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.tasks,
  routes: [
    GoRoute(
      path: AppRoutes.onboarding,
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: AppRoutes.profile,
      builder: (context, state) => const ProfileScreen(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          _HomeShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.tasks,
              builder: (context, state) => const TaskListScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.calendar,
              builder: (context, state) => const CalendarScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);

class _HomeShell extends StatelessWidget {
  const _HomeShell({required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: navigationShell,
      bottomNavigationBar: AppBottomNav(
        currentIndex: navigationShell.currentIndex,
        onIndexChanged: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        onAddPressed: () {},
      ),
    );
  }
}
