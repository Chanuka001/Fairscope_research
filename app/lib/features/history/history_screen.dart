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
        title: const Text('History'),
        centerTitle: false,
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
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search by ID or label',
                  prefixIcon: const Icon(Icons.search_rounded, color: AppColors.secondaryText),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.tune_rounded, color: AppColors.secondaryText),
                    onPressed: () {},
                  ),
                ),
              ),
            ),

            // History Records List
            Expanded(
              child: ListView(
                padding: AppSpacing.screenPaddingAll,
                children: [
                  _buildHistoryCard(
                    id: 'FS-0003',
                    condition: 'Normal skin',
                    timestamp: '16 Sep 2026 • 14:32',
                    onTap: () {
                      // Opens the scan result in the 4-step flow
                      navController.setTab(0);
                      navController.goToStep(2);
                    },
                  ),
                  const SizedBox(height: AppSpacing.s12),
                  _buildHistoryCard(
                    id: 'FS-0002',
                    condition: 'Dry skin',
                    timestamp: '14 Sep 2026 • 11:20',
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
                      style: AppTextStyles.caption,
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
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadii.brLarge,
        side: const BorderSide(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s16,
          vertical: AppSpacing.s8,
        ),
        leading: Container(
          width: 48.0,
          height: 48.0,
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: AppRadii.brMedium,
          ),
          child: const Icon(
            Icons.face_rounded,
            color: AppColors.primary,
          ),
        ),
        title: Row(
          children: [
            Text(
              id,
              style: AppTextStyles.label.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: AppSpacing.s8),
            Text(
              condition,
              style: AppTextStyles.label.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            runSpacing: 4.0,
            children: [
              Text(timestamp, style: AppTextStyles.caption),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: AppRadii.brSmall,
                ),
                child: Text(
                  'Placeholder model',
                  style: AppTextStyles.caption.copyWith(fontSize: 10.0),
                ),
              ),
            ],
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios_rounded,
          size: 14.0,
          color: AppColors.secondaryText,
        ),
        onTap: onTap,
      ),
    );
  }
}

