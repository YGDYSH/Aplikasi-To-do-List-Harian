import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:aplikasi_to_do_list/core/constants/app_strings.dart';
import 'package:aplikasi_to_do_list/core/router/app_router.dart';
import 'package:aplikasi_to_do_list/core/theme/app_colors.dart';
import 'package:aplikasi_to_do_list/core/theme/text_styles.dart';
import 'package:aplikasi_to_do_list/core/widgets/empty_state.dart';
import 'package:aplikasi_to_do_list/core/widgets/gradient_header.dart';
import 'package:aplikasi_to_do_list/core/widgets/task_card.dart';
import 'package:aplikasi_to_do_list/data/repositories/task_repository.dart';
import '../providers/task_providers.dart';

class TaskListScreen extends ConsumerWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupedAsync = ref.watch(groupedTasksProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _TaskListHeader(sortOption: ref.watch(sortOptionProvider)),
        Expanded(
          child: groupedAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
            error: (error, stackTrace) => Center(
              child: Text(
                AppStrings.taskLoadError,
                style: TextStyles.bodyMuted,
              ),
            ),
            data: (state) {
              if (state.isEmpty) {
                return const EmptyState(body: AppStrings.tasksPlaceholder);
              }
              return _GroupedTaskList(state: state);
            },
          ),
        ),
      ],
    );
  }
}

class _TaskListHeader extends StatelessWidget {
  const _TaskListHeader({required this.sortOption});

  final SortOption sortOption;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateText = DateFormat(
      'd MMMM',
      AppStrings.localeId,
    ).format(now);

    return GradientHeader(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 4),
                child: Icon(
                  Icons.grid_view_rounded,
                  size: 20,
                  color: AppColors.surface,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(child: _SearchField()),
              const SizedBox(width: 10),
              _SortMenu(current: sortOption),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            '${AppStrings.todayGreeting}, $dateText',
            style: TextStyles.headerCaption.copyWith(
              color: AppColors.surface.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 4),
          Text(AppStrings.tasksTitle, style: TextStyles.headerTitle),
        ],
      ),
    );
  }
}

class _SearchField extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextField(
      onChanged: (value) =>
          ref.read(searchQueryProvider.notifier).state = value,
      style: TextStyles.body.copyWith(color: AppColors.surface),
      cursorColor: AppColors.surface,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: AppStrings.searchTasksHint,
        filled: true,
        fillColor: AppColors.surface.withValues(alpha: 0.18),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        hintStyle: TextStyles.bodyMuted.copyWith(
          color: AppColors.surface.withValues(alpha: 0.75),
        ),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(AppColors.chipRadius),
          ),
          borderSide: BorderSide.none,
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(AppColors.chipRadius),
          ),
          borderSide: BorderSide.none,
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(AppColors.chipRadius),
          ),
          borderSide: BorderSide(color: Colors.white, width: 1.4),
        ),
        isDense: true,
      ),
    );
  }
}

class _SortMenu extends ConsumerWidget {
  const _SortMenu({required this.current});

  final SortOption current;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<SortOption>(
      icon: const Icon(
        Icons.more_horiz_rounded,
        color: AppColors.surface,
      ),
      tooltip: AppStrings.sortTitle,
      color: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(AppColors.pageRadius)),
      ),
      onSelected: (option) => ref.read(sortOptionProvider.notifier).state = option,
      itemBuilder: (context) => [
        for (final option in SortOption.values)
          PopupMenuItem<SortOption>(
            value: option,
            child: Row(
              children: [
                Icon(
                  option == current
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_unchecked_rounded,
                  size: 18,
                  color: option == current
                      ? AppColors.primary
                      : AppColors.textMuted,
                ),
                const SizedBox(width: 10),
                Text(sortOptionLabel(option), style: TextStyles.body),
              ],
            ),
          ),
      ],
    );
  }
}

class _GroupedTaskList extends ConsumerWidget {
  const _GroupedTaskList({required this.state});

  final GroupedTasksState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        for (final section in state.sections) ...[
          _SectionHeader(title: section.title, count: section.tasks.length),
          for (final task in section.tasks)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: _DismissibleTaskCard(
                item: state.itemsById[task.id]!,
                isOverdue: section.overdueTaskIds.contains(task.id),
              ),
            ),
        ],
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.count});

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title.toUpperCase(),
          style: TextStyles.sectionTitle.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            borderRadius: const BorderRadius.all(
              Radius.circular(AppColors.chipRadius),
            ),
          ),
          child: Text(
            groupBadgeText(count),
            style: TextStyles.caption.copyWith(
              color: AppColors.primary,
              fontSize: 10,
            ),
          ),
        ),
      ],
    );
  }
}

class _DismissibleTaskCard extends ConsumerWidget {
  const _DismissibleTaskCard({
    required this.item,
    required this.isOverdue,
  });

  final TaskWithLabels item;
  final bool isOverdue;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: ValueKey('task-item-${item.task.id}'),
      direction: DismissDirection.endToStart,
      background: _DeleteBackground(),
      onDismissed: (_) => _dismiss(context, ref),
      child: TaskCard(
        title: item.task.title,
        dateText: item.task.dueDate == null
            ? null
            : formatTaskDate(
                item.task.dueDate!,
                now: DateTime.now(),
              ),
        isDone: item.task.isDone,
        isOverdue: isOverdue,
        labels: [
          for (final label in item.labels)
            LabelChipData(
              id: label.id,
              name: label.name,
              colorValue: label.colorValue,
            ),
        ],
        onToggleDone: () => ref
            .read(groupedTasksProvider.notifier)
            .toggleDone(item.task.id, done: !item.task.isDone),
        onOpenDetails: () => context.go(
          '${AppRoutes.editTask}/${item.task.id}',
        ),
      ),
    );
  }

  Future<void> _dismiss(BuildContext context, WidgetRef ref) async {
    final notifier = ref.read(groupedTasksProvider.notifier);
    await notifier.deleteTask(item);

    if (!context.mounted) return;
    var messenger = ScaffoldMessenger.maybeOf(context);
    messenger?.hideCurrentSnackBar();
    // Snackbar untuk urungkan penghapusan (±4 detik).
    messenger?.showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 4),
        content: Text(AppStrings.taskDeleted),
        action: SnackBarAction(
          label: AppStrings.undoAction,
          onPressed: () => notifier.restoreDeleted(),
        ),
      ),
    );
  }
}

class _DeleteBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      margin: const EdgeInsets.only(top: 10),
      decoration: const BoxDecoration(
        color: AppColors.danger,
        borderRadius: BorderRadius.all(Radius.circular(AppColors.pageRadius)),
      ),
      child: const Icon(
        Icons.delete_outline_rounded,
        color: AppColors.surface,
      ),
    );
  }
}
