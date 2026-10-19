import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:aplikasi_to_do_list/core/theme/app_colors.dart';
import 'package:aplikasi_to_do_list/core/widgets/app_bottom_nav.dart';
import 'package:aplikasi_to_do_list/features/calendar/presentation/calendar_screen.dart';
import 'package:aplikasi_to_do_list/features/dashboard/presentation/dashboard_screen.dart';
import 'package:aplikasi_to_do_list/features/onboarding/presentation/onboarding_screen.dart';
import 'package:aplikasi_to_do_list/features/profile/presentation/profile_screen.dart';
import 'package:aplikasi_to_do_list/features/profile/providers/profile_provider.dart';
import 'package:aplikasi_to_do_list/features/tasks/presentation/add_task_sheet.dart';
import 'package:aplikasi_to_do_list/features/tasks/presentation/edit_task_screen.dart';
import 'package:aplikasi_to_do_list/features/tasks/presentation/task_list_screen.dart';

class AppRoutes {
  const AppRoutes._();

  static const onboarding = '/';
  static const profile = '/profile';
  static const tasks = '/home/tasks';
  static const calendar = '/home/calendar';
  static const dashboard = '/home/dashboard';
  static const editTask = '/task/edit';
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final profile = ref.watch(profileControllerProvider.notifier);

  final router = GoRouter(
    initialLocation: AppRoutes.onboarding,
    refreshListenable: profile,
    redirect: (context, state) {
      final location = state.matchedLocation;
      final isOnboarding = location == AppRoutes.onboarding;
      final isProfile = location == AppRoutes.profile;

      if (!profile.onboardingDone) {
        return isOnboarding ? null : AppRoutes.onboarding;
      }
      if (!profile.isReady) {
        return isProfile ? null : AppRoutes.profile;
      }
      return (isOnboarding || isProfile) ? AppRoutes.tasks : null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '${AppRoutes.editTask}/:id',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '');
          if (id == null) {
            return const SizedBox.shrink();
          }
          return EditTaskScreen(taskId: id);
        },
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
          // Dasbor (Bagian 3.3) masuk shell agar tetap punya bottom bar
          // + FAB, tapi tidak menjadi tab AppBottomNav.
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.dashboard,
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );

  ref.onDispose(router.dispose);
  return router;
});

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
        onAddPressed: () => showAddTaskSheet(context),
      ),
    );
  }
}
