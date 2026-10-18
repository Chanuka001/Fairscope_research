import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/state/nav_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

/// History Screen: Displays list of analysed scans (Owned by Member C)
class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navController = ref.read(navigationControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'History',
          style: AppTextStyles.headline.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.text,
          ),
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: AppColors.background,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding,
                vertical: AppSpacing.s8,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadii.medium),
                  border: Border.all(color: AppColors.border),
                  boxShadow: AppShadows.level1,
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search by ID or label',
                    hintStyle: AppTextStyles.body.copyWith(
                      color: AppColors.secondaryText,
                      fontSize: 14.0,
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: AppColors.secondaryText,
                      size: 20.0,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.s16,
                      vertical: AppSpacing.s12,
                    ),
                  ),
                ),
              ),
            ),

            // History Records List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding, vertical: AppSpacing.s8),
                children: [
                  _buildHistoryCard(
                    id: 'FS-0003',
                    condition: 'Normal skin',
                    timestamp: '16 Sep 2026 • 14:32',
                    avatarAsset: 'assets/images/avatas/user_avatar_type_II.png',
                    onTap: () {
                      navController.setTab(0);
                      navController.goToStep(2);
                    },
                  ),
                  const SizedBox(height: AppSpacing.s12),
                  _buildHistoryCard(
                    id: 'FS-0002',
                    condition: 'Dry skin',
                    timestamp: '14 Sep 2026 • 11:20',
                    avatarAsset: 'assets/images/avatas/user_avatar_type_IV.png',
                    onTap: () {
                      navController.setTab(0);
                      navController.goToStep(2);
                    },
                  ),
                  const SizedBox(height: AppSpacing.s12),
                  _buildHistoryCard(
                    id: 'FS-0001',
                    condition: 'Oily skin',
                    timestamp: '12 Sep 2026 • 09:15',
                    avatarAsset: 'assets/images/avatas/user_avatar_type_V.png',
                    onTap: () {
                      navController.setTab(0);
                      navController.goToStep(2);
                    },
                  ),
                  const SizedBox(height: AppSpacing.s24),
                  Center(
                    child: Text(
                      'Only analysed captures are saved to History.\nData stays locally in private storage.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.secondaryText,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryCard({
    required String id,
    required String condition,
    required String timestamp,
    required String avatarAsset,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.large),
        side: const BorderSide(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.s12),
          child: Row(
            children: [
              Container(
                width: 52.0,
                height: 52.0,
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(AppRadii.medium),
                  border: Border.all(color: AppColors.border),
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.asset(
                  avatarAsset,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const Icon(
                    Icons.face_rounded,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          id,
                          style: AppTextStyles.label.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.s8),
                        Text(
                          condition,
                          style: AppTextStyles.label.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.text,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4.0),
                    Row(
                      children: [
                        Text(
                          timestamp,
                          style: AppTextStyles.caption.copyWith(color: AppColors.secondaryText),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(AppRadii.extraSmall),
                          ),
                          child: Text(
                            'Placeholder model',
                            style: AppTextStyles.caption.copyWith(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.onPrimaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.s8),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14.0,
                color: AppColors.secondaryText,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
