import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/utils/task_grouping.dart';
import '../../../core/widgets/gradient_header.dart';
import '../../../data/db/app_database.dart';
import '../../../data/repositories/task_repository.dart';
import '../../stats/presentation/stats_summary_card.dart';
import '../providers/calendar_providers.dart';

/// Layar Kalender (Bagian 3.6): mode Bulan & Minggu, titik penanda tugas,
/// seksi Tugas Terjadwal, dan kartu statistik bila hari tanpa tugas.
/// Jam ditampilkan dalam WIB (format 24 jam).
class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  CalendarFormat _format = CalendarFormat.month;

  void _selectDay(DateTime day) {
    ref.read(calendarSelectedDayProvider.notifier).state =
        TugaskuDateUtils.startOfDay(day);
  }

  void _setFormat(CalendarFormat format) {
    setState(() => _format = format);
  }

  @override
  Widget build(BuildContext context) {
    final selectedDay = ref.watch(calendarSelectedDayProvider);
    final tasksAsync = ref.watch(calendarTasksProvider);
    final items = tasksAsync.value ?? const <TaskWithLabels>[];
    final dueOnDay = [
      for (final item in items)
        if (item.task.dueDate != null &&
            TugaskuDateUtils.isSameDay(item.task.dueDate!.toLocal(), selectedDay))
          item,
    ];

    final isWeekMode = _format == CalendarFormat.week;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GradientHeader(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CalendarSearchField(),
              const SizedBox(height: 18),
              Text(AppStrings.calendarTitle, style: TextStyles.headerTitle),
              const SizedBox(height: 10),
              Row(
                children: [
                  _ModeChip(
                    icon: Icons.calendar_view_month_rounded,
                    label: AppStrings.calendarModeMonth,
                    selected: !isWeekMode,
                    onTap: () => _setFormat(CalendarFormat.month),
                  ),
                  const SizedBox(width: 10),
                  _ModeChip(
                    icon: Icons.calendar_view_week_rounded,
                    label: AppStrings.calendarModeWeek,
                    selected: isWeekMode,
                    onTap: () => _setFormat(CalendarFormat.week),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _CalendarCard(
                  format: _format,
                  selectedDay: selectedDay,
                  items: items,
                  onSelectDay: _selectDay,
                ),
                const SizedBox(height: 16),
                if (isWeekMode) ...[
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          AppStrings.calendarTasksScheduledToday(
                            dueOnDay.length,
                          ),
                          style: TextStyles.bodyMuted,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _setFormat(CalendarFormat.month),
                        child: Text(
                          AppStrings.viewAllLink,
                          style: TextStyles.body.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
                _ScheduledSectionHeader(
                  count: dueOnDay.length,
                  selectedDay: selectedDay,
                  isWeekMode: isWeekMode,
                ),
                const SizedBox(height: 10),
                if (dueOnDay.isEmpty)
                  const StatsSummaryCard()
                else
                  for (final item in dueOnDay)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _ScheduledTaskCard(item: item),
                    ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ---------- Header ----------

class _CalendarSearchField extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextField(
      onChanged: (value) {
        ref.read(calendarSearchQueryProvider.notifier).state = value;
      },
      style: TextStyles.body.copyWith(color: AppColors.surface),
      cursorColor: AppColors.surface,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: AppStrings.searchScheduleHint,
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
          borderRadius: BorderRadius.all(Radius.circular(AppColors.chipRadius)),
          borderSide: BorderSide.none,
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppColors.chipRadius)),
          borderSide: BorderSide(color: Colors.white, width: 1.4),
        ),
        isDense: true,
      ),
    );
  }
}

class _ModeChip extends StatelessWidget {
  const _ModeChip({
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.surface
              : AppColors.surface.withValues(alpha: 0.14),
          borderRadius: const BorderRadius.all(
            Radius.circular(AppColors.chipRadius),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: selected ? AppColors.primary : AppColors.surface,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyles.caption.copyWith(
                color: selected ? AppColors.primary : AppColors.surface,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------- Kasus kalender ----------

class _CalendarCard extends StatelessWidget {
  const _CalendarCard({
    required this.format,
    required this.selectedDay,
    required this.items,
    required this.onSelectDay,
  });

  final CalendarFormat format;
  final DateTime selectedDay;
  final List<TaskWithLabels> items;
  final ValueChanged<DateTime> onSelectDay;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.all(
          Radius.circular(AppColors.pageRadius),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: TableCalendar<Task>(
        firstDay: DateTime.now().subtract(const Duration(days: 365)),
        lastDay: DateTime.now().add(const Duration(days: 365 * 2)),
        focusedDay: selectedDay,
        selectedDayPredicate: (day) => TugaskuDateUtils.isSameDay(day, selectedDay),
        onDaySelected: (selected, focused) => onSelectDay(selected),
        eventLoader: (day) {
          return [
            for (final item in items)
              if (item.task.dueDate != null &&
                  TugaskuDateUtils.isSameDay(
                    item.task.dueDate!.toLocal(),
                    day,
                  ))
                item.task,
          ];
        },
        calendarFormat: format,
        availableCalendarFormats: const {
          CalendarFormat.month: AppStrings.calendarModeMonth,
          CalendarFormat.week: AppStrings.calendarModeWeek,
        },
        startingDayOfWeek: StartingDayOfWeek.monday,
        locale: AppStrings.localeId,
        daysOfWeekHeight: 32,
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: TextStyles.caption.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
          weekendStyle: TextStyles.caption.copyWith(
            color: AppColors.textMuted,
            fontWeight: FontWeight.w700,
          ),
        ),
        rowHeight: 40,
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: false,
          titleTextStyle: TextStyles.screenTitle.copyWith(fontSize: 18),
          leftChevronIcon: const Icon(
            Icons.chevron_left_rounded,
            color: AppColors.textMuted,
          ),
          rightChevronIcon: const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.textMuted,
          ),
        ),
        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,
          selectedDecoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          todayDecoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          todayTextStyle: TextStyles.body.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
          selectedTextStyle: TextStyles.body.copyWith(
            color: AppColors.surface,
            fontWeight: FontWeight.w700,
          ),
          weekendTextStyle: TextStyles.caption.copyWith(
            color: AppColors.textMuted,
          ),
          defaultTextStyle: TextStyles.body,
        ),
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, day, events) {
            if (events.isEmpty) return null;
            return Positioned(
              bottom: 5,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (final task in events.take(3))
                    Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.symmetric(horizontal: 1),
                      decoration: BoxDecoration(
                        color: task.isDone ? AppColors.success : AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// ---------- Seksi daftar tugas terjadwal ----------

class _ScheduledSectionHeader extends StatelessWidget {
  const _ScheduledSectionHeader({
    required this.count,
    required this.selectedDay,
    required this.isWeekMode,
  });

  final int count;
  final DateTime selectedDay;
  final bool isWeekMode;

  @override
  Widget build(BuildContext context) {
    final title = isWeekMode
        ? AppStrings.weekTasksSection
        : AppStrings.scheduledTasksSection;
    final dateBadge = DateFormat('d MMM', AppStrings.localeId)
        .format(selectedDay);

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
            dateBadge,
            style: TextStyles.caption.copyWith(
              color: AppColors.primary,
              fontSize: 10,
            ),
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
            '$count ${AppStrings.taskUnit}',
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

class _ScheduledTaskCard extends StatelessWidget {
  const _ScheduledTaskCard({required this.item});

  final TaskWithLabels item;

  String get _timeText {
    final task = item.task;
    final dueDate = task.dueDate!;
    if (!task.hasTime) {
      return DateFormat('d MMMM', AppStrings.localeId).format(dueDate.toLocal());
    }
    final hourMinutes = DateFormat('HH:mm').format(dueDate.toLocal());
    return AppStrings.taskTimeRange(hourMinutes);
  }

  @override
  Widget build(BuildContext context) {
    final task = item.task;
    final titleStyle = task.isDone
        ? TextStyles.cardTitle.copyWith(
            color: AppColors.textMuted,
            decoration: TextDecoration.lineThrough,
            decorationColor: AppColors.textMuted,
          )
        : TextStyles.cardTitle;
    final overdue = isTaskOverdue(
      dueDate: task.dueDate,
      isDone: task.isDone,
      now: DateTime.now(),
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.all(
          Radius.circular(AppColors.pageRadius),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              task.hasTime
                  ? Icons.schedule_rounded
                  : Icons.calendar_month_rounded,
              size: 18,
              color: task.isDone ? AppColors.textMuted : AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: titleStyle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  _timeText,
                  style: TextStyles.caption.copyWith(
                    color: overdue ? AppColors.danger : AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          _StatusDot(status: task.status),
        ],
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  const _StatusDot({required this.status});

  final int status;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: AppColors.statusColor(status),
        shape: BoxShape.circle,
      ),
    );
  }
}
