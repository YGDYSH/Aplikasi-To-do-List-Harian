import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/widgets/gradient_header.dart';
import '../../../data/providers.dart';
import '../../../data/repositories/task_repository.dart';
import '../providers/task_providers.dart';

/// Papan Kanban (Tahap 5): 3 kolom status dengan drag & drop antar
/// kolom. Tap kartu membuka layar Ubah Tugas.
class KanbanScreen extends ConsumerWidget {
  const KanbanScreen({super.key});

  static const _columns = <(int, String, Color)>[
    (0, AppStrings.statusNotStarted, AppColors.danger),
    (1, AppStrings.statusInProgress, AppColors.warning),
    (2, AppStrings.statusCompleted, AppColors.success),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(allTasksWithLabelsProvider);
    final items = itemsAsync.value ?? const <TaskWithLabels>[];
    final total = items.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GradientHeader(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$total ${AppStrings.taskUnit}',
                style: TextStyles.headerCaption.copyWith(
                  color: AppColors.surface.withValues(alpha: 0.85),
                ),
              ),
              const SizedBox(height: 4),
              Text(AppStrings.kanbanTitle, style: TextStyles.headerTitle),
            ],
          ),
        ),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final (status, label, color) in _columns)
                Expanded(
                  child: _KanbanColumn(
                    status: status,
                    label: label,
                    color: color,
                    items: [
                      for (final item in items)
                        if (item.task.status == status) item,
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _KanbanColumn extends ConsumerWidget {
  const _KanbanColumn({
    required this.status,
    required this.label,
    required this.color,
    required this.items,
  });

  final int status;
  final String label;
  final Color color;
  final List<TaskWithLabels> items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DragTarget<int>(
      onAcceptWithDetails: (details) {
        final taskId = details.data;
        ref
            .read(groupedTasksProvider.notifier)
            .moveTaskToStatus(taskId, status);
      },
      builder: (context, candidates, rejected) {
        return Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: const BorderRadius.all(
              Radius.circular(AppColors.pageRadius),
            ),
            border: candidates.isNotEmpty
                ? Border.all(color: color, width: 2)
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyles.chip,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '${candidates.isNotEmpty ? '+1' : items.length}',
                    style: TextStyles.caption,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView(
                  children: [
                    for (final item in items)
                      _KanbanCard(
                        item: item,
                        onOpen: () => context.push(
                          '${AppRoutes.editTask}/${item.task.id}',
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _KanbanCard extends StatelessWidget {
  const _KanbanCard({required this.item, required this.onOpen});

  final TaskWithLabels item;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final task = item.task;
    String? dateText;
    if (task.dueDate != null) {
      final local = task.dueDate!.toLocal();
      dateText = task.hasTime
          ? DateFormat('d MMM • HH:mm', AppStrings.localeId).format(local)
          : DateFormat('d MMM', AppStrings.localeId).format(local);
    }

    return Draggable<int>(
      data: task.id,
      feedback: _KanbanGhostCard(title: task.title),
      childWhenDragging: Opacity(opacity: 0.4, child: _body(dateText)),
      child: GestureDetector(
        onTap: onOpen,
        child: _body(dateText),
      ),
    );
  }

  Widget _body(String? dateText) {
    final task = item.task;
    final titleStyle = task.isDone
        ? TextStyles.cardTitle.copyWith(
            color: AppColors.textMuted,
            decoration: TextDecoration.lineThrough,
            decorationColor: AppColors.textMuted,
          )
        : TextStyles.cardTitle;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: AppColors.surface,
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              task.title,
              style: titleStyle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (dateText != null) ...[
              const SizedBox(height: 4),
              Text(dateText, style: TextStyles.caption),
            ],
            if (task.repeatRule != null) ...[
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.repeat_rounded,
                    size: 12,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      repeatValueLabel(task.repeatRule),
                      style: TextStyles.caption,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _KanbanGhostCard extends StatelessWidget {
  const _KanbanGhostCard({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: const BorderRadius.all(Radius.circular(12)),
      elevation: 6,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Text(
          title,
          style: TextStyles.cardTitle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
