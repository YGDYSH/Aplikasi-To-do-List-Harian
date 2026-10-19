import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:aplikasi_to_do_list/core/constants/app_strings.dart';
import 'package:aplikasi_to_do_list/core/router/app_router.dart';
import 'package:aplikasi_to_do_list/core/theme/app_colors.dart';
import 'package:aplikasi_to_do_list/core/theme/text_styles.dart';
import 'package:aplikasi_to_do_list/features/profile/providers/profile_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _nameController = TextEditingController();
  bool _initialised = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _start() {
    final profile = ref.read(profileControllerProvider);
    profile.setUserName(_nameController.text);
    context.go(AppRoutes.tasks);
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileControllerProvider);
    if (!_initialised) {
      _initialised = true;
      _nameController.text = profile.userName;
    }

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 40,
                  color: AppColors.surface,
                ),
              ),
              const Spacer(),
              Text(AppStrings.profileTitle, style: TextStyles.displayTitle),
              const SizedBox(height: 8),
              Text(AppStrings.profileSubtitle, style: TextStyles.bodyMuted),
              const SizedBox(height: 28),
              Text(AppStrings.nameLabel, style: TextStyles.sectionTitle),
              const SizedBox(height: 10),
              TextField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _start(),
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  hintText: AppStrings.nameHint,
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      _nameController.text.trim().isEmpty ? null : _start,
                  child: Text(AppStrings.startButton),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
