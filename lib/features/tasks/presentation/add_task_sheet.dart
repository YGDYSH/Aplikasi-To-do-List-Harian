import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../data/db/app_database.dart';
import '../../../core/utils/task_parser.dart';
import '../providers/task_providers.dart';
import 'label_picker_dialog.dart';
import 'priority_picker_dialog.dart';
import 'repeat_picker_dialog.dart';

Future<void> showAddTaskSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: AppColors.textPrimary.withValues(alpha: 0.45),
    builder: (_) => const _AddTaskSheetRoot(),
  );
}

class _AddTaskSheetRoot extends StatelessWidget {
  const _AddTaskSheetRoot();

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
      child: const AddTaskSheet(),
    );
  }
}

class AddTaskSheet extends ConsumerStatefulWidget {
  const AddTaskSheet({super.key});

  @override
  ConsumerState<AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends ConsumerState<AddTaskSheet> {
  final _titleController = TextEditingController();
  final _noteController = TextEditingController();

  DateTime? _dueDate;
  bool _hasTime = false;
  int _priority = 0;
  String? _repeatRule;
  Set<int> _labelIds = {};

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  bool get _canSubmit => _titleController.text.trim().isNotEmpty;

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate?.toLocal() ?? now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365 * 3)),
    );
    if (picked == null) return;
    setState(() {
      final time = _hasTime ? _timeOfDay : null;
      _dueDate = DateTime(
        picked.year,
        picked.month,
        picked.day,
        time?.hour ?? 9,
        time?.minute ?? 0,
      );
    });
  }

  TimeOfDay? get _timeOfDay {
    if (!_hasTime || _dueDate == null) return null;
    final local = _dueDate!.toLocal();
    return TimeOfDay(hour: local.hour, minute: local.minute);
  }

  Future<void> _pickTime() async {
    final initial = _timeOfDay ?? TimeOfDay.now();
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked == null) return;
    // Izin notifikasi diminta saat pengguna pertama mengatur pengingat.
    await ref.read(notificationServiceProvider).requestPermissionIfNeeded();
    setState(() {
      final date = _dueDate ?? DateTime.now();
      _dueDate = DateTime(
        date.year,
        date.month,
        date.day,
        picked.hour,
        picked.minute,
      );
      _hasTime = true;
    });
  }

  Future<void> _pickPriorities() async {
    final picked = await showPriorityPickerDialog(context);
    if (picked == null) return;
    setState(() => _priority = picked);
  }

  Future<void> _pickRepeat() async {
    final picked = await showRepeatPickerDialog(context);
    if (picked == null) return; // dibatalkan
    setState(() => _repeatRule = picked.isEmpty ? null : picked);
  }

  Future<void> _pickLabels() async {
    final labels = ref.read(labelsStreamProvider).value ?? const <Label>[];
    final result = await showLabelPickerDialog(
      context,
      labels: labels,
      selected: _labelIds,
    );
    if (result == null) return;
    setState(() => _labelIds = result);
  }

  Future<void> _submit() async {
    final controller = _titleController.text;
    final rawTitle = controller.trim();
    if (rawTitle.isEmpty) return;

    // Parsing bahasa natural dipakai hanya bila tanggal belum dipilih
    // lewat picker, sehingga pilihan manual selalu menang.
    var effectiveTitle = rawTitle;
    var effectiveDueDate = _dueDate;
    var effectiveHasTime = _hasTime;
    if (_dueDate == null) {
      final parsed = parseTaskPhrase(rawTitle, now: DateTime.now());
      if (parsed.dueDate != null || parsed.title != rawTitle) {
        effectiveTitle = parsed.title;
        effectiveDueDate = parsed.dueDate;
        effectiveHasTime = parsed.hasTime;
      }
    }

    await ref.read(groupedTasksProvider.notifier).addTask(
          title: effectiveTitle,
          note: _noteController.text,
          dueDate: effectiveDueDate,
          hasTime: effectiveHasTime,
          priority: _priority,
          repeatRule: _repeatRule,
          // Pengingat otomatis mengikuti jam tugas bila jam dipilih.
          reminderAt: effectiveHasTime ? effectiveDueDate : null,
          labelIds: _labelIds.toList(),
        );

    if (mounted) Navigator.of(context).pop();
  }

  String get _dateBadge {
    if (_dueDate == null) return '';
    final local = _dueDate!.toLocal();
    return '${local.day}/${local.month}';
  }

  String get _timeBadge {
    if (!_hasTime || _dueDate == null) return '';
    final local = _dueDate!.toLocal();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textMuted.withValues(alpha: 0.4),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(AppColors.chipRadius),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: const BorderRadius.all(
                    Radius.circular(AppColors.chipRadius),
                  ),
                  border: Border.all(color: AppColors.primaryLight),
                ),
                child: Text(
                  AppStrings.addTaskPrompt,
                  style: TextStyles.caption
                      .copyWith(color: AppColors.textPrimary),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    controller: _titleController,
                    autofocus: true,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _submit(),
                    onChanged: (_) => setState(() {}),
                    style: TextStyles.body.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: const InputDecoration(
                      hintText: AppStrings.addTaskHint,
                      filled: false,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                _SubmitButton(
                  enabled: _canSubmit,
                  onPressed: _submit,
                ),
              ],
            ),
            if (_hasTime) ...[
              const SizedBox(height: 8),
              Text(AppStrings.reminderHint, style: TextStyles.caption),
            ],
            const SizedBox(height: 6),
            Text(
              AppStrings.quickParseIconTooltip,
              style: TextStyles.caption,
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _ActionIcon(
                  icon: Icons.calendar_today_rounded,
                  tooltip: AppStrings.dateIconTooltip,
                  badge: _dateBadge,
                  active: _dueDate != null,
                  onTap: _pickDate,
                ),
                _ActionIcon(
                  icon: Icons.schedule_rounded,
                  tooltip: AppStrings.timeIconTooltip,
                  badge: _timeBadge,
                  active: _hasTime,
                  onTap: _hasTime
                      ? () => setState(() => _hasTime = false)
                      : _pickTime,
                ),
                _ActionIcon(
                  icon: Icons.flag_rounded,
                  tooltip: AppStrings.priorityIconTooltip,
                  badge: priorityValueLabel(_priority),
                  active: _priority > 0,
                  onTap: _pickPriorities,
                ),
                _ActionIcon(
                  icon: Icons.repeat_rounded,
                  tooltip: AppStrings.repeatIconTooltip,
                  badge: _repeatRule == null
                      ? ''
                      : repeatValueLabel(_repeatRule),
                  active: _repeatRule != null,
                  onTap: _pickRepeat,
                ),
                _ActionIcon(
                  icon: Icons.label_rounded,
                  tooltip: AppStrings.labelIconTooltip,
                  badge: _labelIds.isEmpty
                      ? ''
                      : _labelIds.length.toString(),
                  active: _labelIds.isNotEmpty,
                  onTap: _pickLabels,
                ),
                _ActionIcon(
                  icon: Icons.notes_rounded,
                  tooltip: AppStrings.noteIconTooltip,
                  badge: '',
                  active: _noteController.text.trim().isNotEmpty,
                  onTap: () => _openNoteField(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openNoteField() async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(AppStrings.noteLabel, style: TextStyles.screenTitle),
        content: TextField(
          controller: _noteController,
          autofocus: true,
          maxLines: 4,
          onChanged: (_) => setState(() {}),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(AppStrings.saveButton),
          ),
        ],
      ),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  const _SubmitButton({required this.enabled, required this.onPressed});

  final bool enabled;
  final Future<void> Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onPressed : null,
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: enabled ? AppColors.primary : AppColors.textMuted,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.arrow_upward_rounded,
            color: AppColors.surface),
      ),
    );
  }
}

class _ActionIcon extends StatelessWidget {
  const _ActionIcon({
    required this.icon,
    required this.tooltip,
    required this.badge,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final String badge;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.primary : AppColors.textMuted;
    return GestureDetector(
      onTap: onTap,
      child: Tooltip(
        message: tooltip,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.10),
            borderRadius: const BorderRadius.all(
              Radius.circular(AppColors.chipRadius),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: color),
              if (badge.isNotEmpty) ...[
                const SizedBox(width: 6),
                Text(badge, style: TextStyles.caption),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
