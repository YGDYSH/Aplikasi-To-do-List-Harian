import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:aplikasi_to_do_list/core/constants/app_strings.dart';
import 'package:aplikasi_to_do_list/core/theme/app_colors.dart';
import 'package:aplikasi_to_do_list/core/theme/text_styles.dart';
import 'package:aplikasi_to_do_list/core/widgets/label_chip.dart';
import 'package:aplikasi_to_do_list/data/db/app_database.dart';
import 'package:aplikasi_to_do_list/data/repositories/task_repository.dart';
import '../providers/task_providers.dart';
import 'label_picker_dialog.dart';
import 'priority_picker_dialog.dart';

class EditTaskScreen extends ConsumerStatefulWidget {
  const EditTaskScreen({super.key, required this.taskId});

  final int taskId;

  @override
  ConsumerState<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends ConsumerState<EditTaskScreen> {
  final _titleController = TextEditingController();
  final _noteController = TextEditingController();

  bool _initialised = false;
  bool _hasTime = false;
  int _priority = 0;
  DateTime? _dueDate;
  Set<int> _labelIds = {};

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _initFromTask(TaskWithLabels item) {
    final task = item.task;
    _initialised = true;
    _titleController.text = task.title;
    _noteController.text = task.note ?? '';
    final dueDate = task.dueDate;
    if (dueDate != null) {
      final local = dueDate.toLocal();
      _dueDate = local;
      _hasTime = task.hasTime && !(local.hour == 0 && local.minute == 0);
    }
    _labelIds = {for (final label in item.labels) label.id};
    _priority = task.priority;
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    final controller = ref.read(groupedTasksProvider.notifier);
    await controller.updateFields(
      taskId: widget.taskId,
      title: title,
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
      dueDate: _dueDate,
      hasTime: _hasTime,
      priority: _priority,
      // Pengingat mengikuti jam tugas bila jam dipilih.
      reminderAt: _hasTime && _dueDate != null ? _dueDate : null,
    );
    await controller.setLabels(widget.taskId, _labelIds.toList());

    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(taskDetailProvider(widget.taskId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: Text(AppStrings.editTaskTitle, style: TextStyles.screenTitle),
        actions: [
          TextButton(
            onPressed: () => _save(),
            child: Text(
              AppStrings.saveButton,
              style: TextStyles.body.copyWith(
                color: _titleController.text.trim().isEmpty
                    ? AppColors.textMuted
                    : AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      body: detailAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (error, stackTrace) => Center(
          child: Text(AppStrings.taskLoadError, style: TextStyles.bodyMuted),
        ),
        data: _buildContent,
      ),
    );
  }

  Widget _buildContent(TaskWithLabels? item) {
    if (item == null) {
      return Center(
        child: Text(AppStrings.taskLoadError, style: TextStyles.bodyMuted),
      );
    }
    if (!_initialised) {
      _initFromTask(item);
    }

    final labelsAsync = ref.watch(labelsStreamProvider);
    final allLabels = labelsAsync.value ?? item.labels;
    final selectedLabels = [
      for (final label in allLabels)
        if (_labelIds.contains(label.id)) label,
    ];

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          TextField(
            controller: _titleController,
            style: TextStyles.cardTitle,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(AppColors.pageRadius),
                ),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(AppColors.pageRadius),
                ),
                borderSide: BorderSide(color: AppColors.primary, width: 1.4),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 16,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Flexible(
                child: _EditActionTile(
                  icon: Icons.calendar_today_rounded,
                  label: AppStrings.dateLabel,
                  value: _dueDate == null
                      ? null
                      : DateFormat(
                          'd MMM yyyy',
                          AppStrings.localeId,
                        ).format(_dueDate!.toLocal()),
                  selected: _dueDate != null,
                  onTap: _pickDate,
                ),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: _EditActionTile(
                  icon: Icons.schedule_rounded,
                  label: AppStrings.timeLabel,
                  value: _timeBadge,
                  selected: _hasTime,
                  onTap: () {
                    if (_hasTime) {
                      setState(() => _hasTime = false);
                    } else {
                      _pickTime();
                    }
                  },
                ),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: _EditActionTile(
                  icon: Icons.flag_rounded,
                  label: priorityValueLabel(_priority),
                  value: null,
                  selected: _priority > 0,
                  onTap: () async {
                    final picked = await showPriorityPickerDialog(context);
                    if (picked == null) return;
                    setState(() => _priority = picked);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _EditActionTile(
            icon: Icons.label_rounded,
            label: AppStrings.labelLabel,
            value: null,
            selected: _labelIds.isNotEmpty,
            onTap: _pickLabels,
          ),
          if (selectedLabels.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final label in selectedLabels)
                    LabelChip(name: label.name, colorValue: label.colorValue),
                ],
              ),
            ),
          const SizedBox(height: 10),
          Text(AppStrings.noteLabel, style: TextStyles.sectionTitle),
          const SizedBox(height: 6),
          TextField(
            controller: _noteController,
            maxLines: 5,
            style: TextStyles.body,
            decoration: const InputDecoration(
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(AppColors.pageRadius),
                ),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(AppColors.pageRadius),
                ),
                borderSide: BorderSide(color: AppColors.primary, width: 1.4),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String? get _timeBadge {
    if (!_hasTime || _dueDate == null) return null;
    final local = _dueDate!.toLocal();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

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
      final withTime = _hasTime ? _dueDate!.toLocal() : null;
      _dueDate = DateTime(
        picked.year,
        picked.month,
        picked.day,
        withTime?.hour ?? 9,
        withTime?.minute ?? 0,
      );
    });
  }

  Future<void> _pickTime() async {
    TimeOfDay? initial;
    if (_hasTime && _dueDate != null) {
      final local = _dueDate!.toLocal();
      initial = TimeOfDay(hour: local.hour, minute: local.minute);
    }
    final picked = await showTimePicker(
      context: context,
      initialTime: initial ?? TimeOfDay.now(),
    );
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

  Future<void> _pickLabels() async {
    final allLabels = ref.read(labelsStreamProvider).value ?? const <Label>[];
    final result = await showLabelPickerDialog(
      context,
      labels: allLabels,
      selected: _labelIds,
    );
    if (result == null) return;
    setState(() => _labelIds = result);
  }
}

class _EditActionTile extends StatelessWidget {
  const _EditActionTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String? value;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.textMuted;
    return Material(
      color: AppColors.surface,
      borderRadius: const BorderRadius.all(
        Radius.circular(AppColors.pageRadius),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: const BorderRadius.all(
          Radius.circular(AppColors.pageRadius),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  value ?? label,
                  style: TextStyles.body.copyWith(
                    color: selected ? AppColors.primary : null,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
