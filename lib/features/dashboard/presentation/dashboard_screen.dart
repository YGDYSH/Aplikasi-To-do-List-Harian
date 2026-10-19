import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/widgets/gradient_header.dart';
import '../../../data/providers.dart';
import '../../profile/providers/profile_provider.dart';
import '../../tasks/providers/task_providers.dart';
import '../providers/dashboard_providers.dart';

/// Layar Dasbor (Bagian 3.3): 3 kartu pintasan, seksi Proyek, Label,
/// Status, header gradien dengan avatar + tombol pengaturan.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userName = ref.watch(profileControllerProvider).userName;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _DashboardHeader(userName: userName),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _ShortcutCards(),
                const SizedBox(height: 16),
                _ProjectsSection(),
                const SizedBox(height: 12),
                _LabelsSection(),
                const SizedBox(height: 12),
                const _StatusSection(),
                const SizedBox(height: 12),
                const _DataSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------- Header ----------

class _DashboardHeader extends ConsumerWidget {
  const _DashboardHeader({required this.userName});

  final String userName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final dateText = DateFormat('d MMMM', AppStrings.localeId).format(now);

    return GradientHeader(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _Avatar(initial: userName.isEmpty ? '' : userName[0]),
              const Spacer(),
              IconButton(
                icon: const Icon(
                  Icons.settings_rounded,
                  color: AppColors.surface,
                  size: 22,
                ),
                tooltip: AppStrings.dashboardSettingsTooltip,
                onPressed: () => _showRenameDialog(context, ref),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${AppStrings.todayGreeting}, $dateText',
            style: TextStyles.headerCaption.copyWith(
              color: AppColors.surface.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 4),
          Text(AppStrings.dashboardTitle, style: TextStyles.headerTitle),
        ],
      ),
    );
  }

  void _showRenameDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController(text: userName);
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(AppStrings.dashboardSettingsTooltip),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: AppStrings.nameHint,
            filled: true,
            fillColor: AppColors.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(AppColors.pageRadius),
              ),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              AppStrings.cancelButton,
              style: TextStyles.body.copyWith(color: AppColors.textMuted),
            ),
          ),
          TextButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                ref
                    .read(profileControllerProvider.notifier)
                    .setUserName(name);
              }
              Navigator.of(dialogContext).pop();
            },
            child: Text(
              AppStrings.saveChangesButton,
              style: TextStyles.body.copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.initial});

  final String initial;

  @override
  Widget build(BuildContext context) {
    final hasInitial = initial.isNotEmpty;
    return CircleAvatar(
      radius: 22,
      backgroundColor: AppColors.surface.withValues(alpha: 0.24),
      child: hasInitial
          ? Text(
              initial.toUpperCase(),
              style: TextStyles.cardTitle.copyWith(
                color: AppColors.surface,
                fontSize: 18,
              ),
            )
          : const Icon(
              Icons.person_rounded,
              color: AppColors.surface,
              size: 22,
            ),
    );
  }
}

// ---------- Kartu pintasan ----------

class _ShortcutCards extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ShortcutCard(
            icon: Icons.check_circle_outline_rounded,
            label: AppStrings.tabTasks,
            onTap: () => context.go(AppRoutes.tasks),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ShortcutCard(
            icon: Icons.calendar_month_rounded,
            label: AppStrings.tabCalendar,
            onTap: () => context.go(AppRoutes.calendar),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ShortcutCard(
            icon: Icons.view_kanban_outlined,
            label: AppStrings.shortcutKanban,
            onTap: () => context.go(AppRoutes.kanban),
          ),
        ),
      ],
    );
  }
}

class _ShortcutCard extends StatelessWidget {
  const _ShortcutCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: const BorderRadius.all(Radius.circular(AppColors.pageRadius)),
      child: InkWell(
        onTap: onTap,
        borderRadius: const BorderRadius.all(
          Radius.circular(AppColors.pageRadius),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Column(
            children: [
              Icon(icon, size: 22, color: AppColors.primary),
              const SizedBox(height: 6),
              Text(label, style: TextStyles.chip),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------- Seksi baris (Proyek / Label) ----------

class _SectionContainer extends StatelessWidget {
  const _SectionContainer({
    required this.title,
    required this.children,
    required this.onAdd,
    required this.emptyText,
  });

  final String title;
  final List<Widget> children;
  final VoidCallback onAdd;
  final String emptyText;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(horizontal: 16),
      initiallyExpanded: true,
      shape: const Border(),
      backgroundColor: AppColors.surface,
      collapsedBackgroundColor: AppColors.surface,
      iconColor: AppColors.textMuted,
      collapsedIconColor: AppColors.textMuted,
      title: Text(
        title.toUpperCase(),
        style: TextStyles.sectionTitle.copyWith(
          color: AppColors.textPrimary,
          fontSize: 13,
        ),
      ),
      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      trailing: IconButton(
        icon: const Icon(Icons.add_circle_rounded, color: AppColors.primary),
        onPressed: onAdd,
      ),
      children: [
        if (children.isEmpty)
          Align(
            alignment: Alignment.centerLeft,
            child: Text(emptyText, style: TextStyles.bodyMuted),
          )
        else for (final child in children) child,
      ],
    );
  }
}

class _ProjectsSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projects = ref.watch(projectsStreamProvider).value;
    final counts = ref.watch(projectTaskCountsProvider);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.all(Radius.circular(AppColors.pageRadius)),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: _SectionContainer(
        title: AppStrings.dashboardProjects,
        onAdd: () => _addProject(context, ref),
        emptyText: AppStrings.noProjectsYet,
        children: [
          if (projects == null || projects.isEmpty)
            Text(AppStrings.noProjectsYet, style: TextStyles.bodyMuted)
          else
            for (final project in projects)
              _ProjectRow(
                name: project.name,
                count: counts[project.id] ?? 0,
              ),
        ],
      ),
    );
  }

  Future<void> _addProject(BuildContext context, WidgetRef ref) async {
    await _showNameDialog(
      context,
      title: AppStrings.addProjectTitle,
      hint: AppStrings.addProjectNameHint,
      onConfirm: (name) async {
        try {
          await ref.read(projectRepositoryProvider).addProject(name);
        } on ArgumentError {
          // Nama kosong — abaikan.
        }
      },
    );
  }
}

class _ProjectRow extends StatelessWidget {
  const _ProjectRow({required this.name, required this.count});

  final String name;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: AppColors.background,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.folder_rounded,
              size: 16,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(name, style: TextStyles.body),
          ),
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
      ),
    );
  }
}

class _LabelsSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final labels = ref.watch(labelsStreamProvider).value;
    final counts = ref.watch(labelTaskCountsProvider);

    return Container(
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
      clipBehavior: Clip.antiAlias,
      child: _SectionContainer(
        title: AppStrings.dashboardLabels,
        onAdd: () => _addLabel(context, ref),
        emptyText: AppStrings.noLabelsYet,
        children: [
          if (labels == null || labels.isEmpty)
            Text(AppStrings.noLabelsYet, style: TextStyles.bodyMuted)
          else
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 3.4,
              children: [
                for (final label in labels)
                  _LabelGridCard(
                    name: label.name,
                    colorValue: label.colorValue,
                    count: counts[label.id] ?? 0,
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Future<void> _addLabel(BuildContext context, WidgetRef ref) async {
    var attempts = 0;
    await _showNameDialog(
      context,
      title: AppStrings.addLabelTitle,
      hint: AppStrings.addLabelNameHint,
      onConfirm: (name) async {
        try {
          // Warna label dipilih berurutan dari palet token.
          final palette = [
            AppColors.labelBelajar,
            AppColors.labelOlahraga,
            AppColors.labelKerja,
            AppColors.labelKebiasaan,
          ];
          final color = palette[attempts % palette.length];
          attempts++;
          await ref.read(labelRepositoryProvider).createLabel(
                name: name,
                colorValue: color.toARGB32(),
              );
        } on ArgumentError {
          // Nama kosong — abaikan.
        } on StateError {
          // Label sudah ada — abaikan (UNIQUE).
        }
      },
    );
  }
}

class _LabelGridCard extends StatelessWidget {
  const _LabelGridCard({
    required this.name,
    required this.colorValue,
    required this.count,
  });

  final String name;
  final int colorValue;
  final int count;

  @override
  Widget build(BuildContext context) {
    final color = Color(colorValue);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: const BorderRadius.all(
          Radius.circular(AppColors.pageRadius),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              name,
              style: TextStyles.chip,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '$count',
            style: TextStyles.caption.copyWith(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

class _StatusSection extends ConsumerWidget {
  const _StatusSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final counts = ref.watch(statusCountsProvider);
    final chips = <(int, String, Color)>[
      (0, AppStrings.statusNotStarted, AppColors.danger),
      (1, AppStrings.statusInProgress, AppColors.warning),
      (2, AppStrings.statusCompleted, AppColors.success),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.dashboardStatus.toUpperCase(),
            style: TextStyles.sectionTitle.copyWith(
              color: AppColors.textPrimary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final (status, label, color) in chips)
                _StatusChip(
                  label: label,
                  color: color,
                  count: counts[status] ?? 0,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.color,
    required this.count,
  });

  final String label;
  final Color color;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: const BorderRadius.all(
          Radius.circular(AppColors.chipRadius),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(label, style: TextStyles.chip),
          const SizedBox(width: 6),
          Text(
            '$count',
            style: TextStyles.caption.copyWith(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

// ---------- Seksi Data (cadangan clipboard) ----------

class _DataSection extends ConsumerWidget {
  const _DataSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.dataSectionLabel.toUpperCase(),
            style: TextStyles.sectionTitle.copyWith(
              color: AppColors.textPrimary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(AppColors.chipRadius),
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.copy_rounded, size: 18),
                  label: Text(AppStrings.exportDataButton),
                  onPressed: () => _exportData(context, ref),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.surface,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(AppColors.chipRadius),
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.paste_rounded, size: 18),
                  label: Text(AppStrings.importDataButton),
                  onPressed: () => _importData(context, ref),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _exportData(BuildContext context, WidgetRef ref) async {
    try {
      final json = await ref.read(backupRepositoryProvider).exportJson();
      await Clipboard.setData(ClipboardData(text: json));
      if (!context.mounted) return;
      _showSnack(context, AppStrings.exportDataDone);
    } on Exception {
      if (!context.mounted) return;
      _showSnack(context, AppStrings.importNontaskJson);
    }
  }

  Future<void> _importData(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          AppStrings.importDialogTitle,
          style: TextStyles.screenTitle.copyWith(fontSize: 18),
        ),
        content: TextField(
          controller: controller,
          maxLines: 5,
          decoration: InputDecoration(
            hintText: AppStrings.importHint,
            filled: true,
            fillColor: AppColors.background,
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(AppColors.pageRadius),
              ),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(
              AppStrings.cancelButton,
              style: TextStyles.body.copyWith(color: AppColors.textMuted),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              AppStrings.importConfirmButton,
              style: TextStyles.body.copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final source = controller.text.trim();
    if (source.isEmpty) return;
    try {
      final imported = await ref
          .read(backupRepositoryProvider)
          .importJson(source);
      if (!context.mounted) return;
      _showSnack(
        context,
        AppStrings.importDone(imported),
      );
    } on Object {
      if (!context.mounted) return;
      _showSnack(context, AppStrings.importNontaskJson);
    }
  }

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: TextStyles.body.copyWith(color: AppColors.surface),
          ),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }
}

/// Dialog masukan nama sederhana yang dipakai Proyek & Label pada Dasbor.
Future<void> _showNameDialog(
  BuildContext context, {
  required String title,
  required String hint,
  required Future<void> Function(String name) onConfirm,
}) async {
  final controller = TextEditingController();
  await showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: AppColors.surface,
      title: Text(title, style: TextStyles.screenTitle.copyWith(fontSize: 18)),
      content: TextField(
        controller: controller,
        autofocus: true,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: AppColors.background,
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(AppColors.pageRadius),
            ),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: Text(
            AppStrings.cancelButton,
            style: TextStyles.body.copyWith(color: AppColors.textMuted),
          ),
        ),
        TextButton(
          onPressed: () async {
            final name = controller.text.trim();
            if (name.isNotEmpty) {
              Navigator.of(dialogContext).pop();
              await onConfirm(name);
            }
          },
          child: Text(
            AppStrings.saveChangesButton,
            style: TextStyles.body.copyWith(color: AppColors.primary),
          ),
        ),
      ],
    ),
  );
}
