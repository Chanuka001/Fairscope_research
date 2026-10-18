import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/navigation/step_indicator.dart';
import '../../../../core/state/nav_state.dart';
import '../../../../core/state/probe_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Step 3: Grad-CAM Explanation & Demographic Fairness Evaluation (Member D research module)
class ExplainScreen extends ConsumerStatefulWidget {
  const ExplainScreen({super.key});

  @override
  ConsumerState<ExplainScreen> createState() => _ExplainScreenState();
}

class _ExplainScreenState extends ConsumerState<ExplainScreen> {
  double _heatmapOpacity = 0.65;

  // Sample data for Fitzpatrick skin tone fairness evaluation (Member D placeholder per Section 12 Task 12)
  final List<Map<String, dynamic>> _fairnessData = const [
    {
      'type': 'Type I',
      'label': 'Pale / Ivory',
      'accuracy': 88.4,
      'avatar': 'assets/images/avatas/user_avatar_type_I.png',
    },
    {
      'type': 'Type II',
      'label': 'Fair',
      'accuracy': 87.2,
      'avatar': 'assets/images/avatas/user_avatar_type_II.png',
    },
    {
      'type': 'Type III',
      'label': 'Medium / Olive',
      'accuracy': 86.8,
      'avatar': 'assets/images/avatas/user_avatar_type_III.png',
    },
    {
      'type': 'Type IV',
      'label': 'Light Brown',
      'accuracy': 85.5,
      'avatar': 'assets/images/avatas/user_avatar_type_IV.png',
    },
    {
      'type': 'Type V',
      'label': 'Brown',
      'accuracy': 84.9,
      'avatar': 'assets/images/avatas/user_avatar_type_V.png',
    },
    {
      'type': 'Type VI',
      'label': 'Dark Brown / Black',
      'accuracy': 84.2,
      'avatar': 'assets/images/avatas/user_avatar_type_VI.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final navController = ref.read(navigationControllerProvider);
    final selectedCapture = ref.watch(selectedCaptureProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.text),
          onPressed: () => navController.handleBack(),
        ),
        title: Column(
          children: [
            Text('Explanation', style: AppTextStyles.title.copyWith(fontWeight: FontWeight.w700)),
            Text('Step 3 of 4', style: AppTextStyles.caption.copyWith(color: AppColors.secondaryText)),
          ],
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: AppSpacing.s16),
            child: StepIndicator(currentStep: 3),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding, vertical: AppSpacing.s12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Heatmap visualizer container with face avatar
              Container(
                width: double.infinity,
                height: 250.0,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadii.large),
                  border: Border.all(color: AppColors.border),
                  boxShadow: AppShadows.level1,
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    selectedCapture != null && selectedCapture.imageBytes.isNotEmpty
                        ? Image.memory(
                            selectedCapture.imageBytes,
                            fit: BoxFit.contain,
                            errorBuilder: (_, _, _) => Image.asset(
                              'assets/images/avatas/explane-image.png',
                              fit: BoxFit.contain,
                              errorBuilder: (_, _, _) => const Icon(
                                Icons.face_rounded,
                                size: 96.0,
                                color: AppColors.primary,
                              ),
                            ),
                          )
                        : Image.asset(
                            'assets/images/avatas/explane-image.png',
                            fit: BoxFit.contain,
                            errorBuilder: (_, _, _) => Image.asset(
                              'assets/images/avatas/user_avatar_type_II.png',
                              fit: BoxFit.contain,
                              errorBuilder: (_, _, _) => const Icon(
                                Icons.face_rounded,
                                size: 96.0,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                    // Realistic Grad-CAM saliency heat overlay
                    Opacity(
                      opacity: _heatmapOpacity,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            center: const Alignment(0.15, 0.05),
                            radius: 0.58,
                            colors: [
                              Colors.redAccent.withValues(alpha: 0.85),
                              Colors.orangeAccent.withValues(alpha: 0.65),
                              Colors.yellowAccent.withValues(alpha: 0.40),
                              Colors.tealAccent.withValues(alpha: 0.15),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.35, 0.60, 0.85, 1.0],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: AppSpacing.s12,
                      right: AppSpacing.s12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s8, vertical: 3.0),
                        decoration: BoxDecoration(
                          color: AppColors.surface.withValues(alpha: 0.95),
                          borderRadius: BorderRadius.circular(AppRadii.small),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Text(
                          'Grad-CAM Heatmap',
                          style: AppTextStyles.caption.copyWith(
                            fontSize: 10.0,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.s16),

              // Heatmap Opacity Slider
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16, vertical: AppSpacing.s8),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadii.large),
                  border: Border.all(color: AppColors.border),
                  boxShadow: AppShadows.level1,
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Heatmap opacity',
                          style: AppTextStyles.label.copyWith(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          '${(_heatmapOpacity * 100).toInt()}%',
                          style: AppTextStyles.caption.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text('0%', style: AppTextStyles.caption.copyWith(fontSize: 11.0)),
                        Expanded(
                          child: SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: AppColors.primary,
                              inactiveTrackColor: AppColors.border,
                              thumbColor: AppColors.primary,
                              trackHeight: AppSpacing.sliderTrackHeight,
                            ),
                            child: Slider(
                              value: _heatmapOpacity,
                              min: 0.0,
                              max: 1.0,
                              onChanged: (val) {
                                setState(() {
                                  _heatmapOpacity = val;
                                });
                              },
                            ),
                          ),
                        ),
                        Text('100%', style: AppTextStyles.caption.copyWith(fontSize: 11.0)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.s16),

              // "Why this result?" Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.cardPadding),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadii.large),
                  border: Border.all(color: AppColors.border),
                  boxShadow: AppShadows.level1,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.lightbulb_rounded,
                          color: AppColors.primary,
                          size: 20.0,
                        ),
                        const SizedBox(width: AppSpacing.s8),
                        Text(
                          'Why this result?',
                          style: AppTextStyles.title.copyWith(fontSize: 16.0, fontWeight: FontWeight.w700),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s8, vertical: 2.0),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(AppRadii.small),
                          ),
                          child: Text(
                            'Sample data',
                            style: AppTextStyles.caption.copyWith(
                              fontSize: 10.0,
                              fontWeight: FontWeight.w600,
                              color: AppColors.secondaryText,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.s12),
                    Text(
                      'The model focused on the cheek and T-zone areas, which are often related to moisture and texture changes in the skin.',
                      style: AppTextStyles.body.copyWith(
                        fontSize: 14.0,
                        height: 1.5,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s8),
                    Text(
                      'Member D (Grad-CAM Explainability Module)',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.secondaryText,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.s16),

              // Sample Fairness across Skin Tones Chart (Section 12 Task 12)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.cardPadding),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadii.large),
                  border: Border.all(color: AppColors.border),
                  boxShadow: AppShadows.level1,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.auto_graph_rounded,
                          color: AppColors.primary,
                          size: 20.0,
                        ),
                        const SizedBox(width: AppSpacing.s8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Fairness across Skin Tones',
                                style: AppTextStyles.title.copyWith(
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                'Fitzpatrick scale (FST I–VI)',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.secondaryText,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s8, vertical: 2.0),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(AppRadii.small),
                          ),
                          child: Text(
                            'Sample data',
                            style: AppTextStyles.caption.copyWith(
                              fontSize: 10.0,
                              fontWeight: FontWeight.w600,
                              color: AppColors.secondaryText,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.s12),

                    // Disparity summary metric chip
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s12, vertical: AppSpacing.s8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(AppRadii.medium),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.verified_rounded,
                            size: 16.0,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: AppSpacing.s8),
                          Expanded(
                            child: Text(
                              'Max Parity Disparity: 4.2% (Within <5% threshold)',
                              style: AppTextStyles.caption.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.onPrimaryContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.s16),

                    // Skin tone rows with avatars and accuracy bars
                    ..._fairnessData.map((item) {
                      final acc = item['accuracy'] as double;
                      final type = item['type'] as String;
                      final label = item['label'] as String;
                      final avatar = item['avatar'] as String;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.s12),
                        child: Row(
                          children: [
                            // Avatar thumbnail
                            Container(
                              width: 32.0,
                              height: 32.0,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.border),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: Image.asset(
                                avatar,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => const Icon(
                                  Icons.person,
                                  size: 20.0,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.s12),
                            // Type and Label
                            SizedBox(
                              width: 80.0,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    type,
                                    style: AppTextStyles.label.copyWith(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12.0,
                                    ),
                                  ),
                                  Text(
                                    label,
                                    style: AppTextStyles.caption.copyWith(
                                      fontSize: 10.0,
                                      color: AppColors.secondaryText,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: AppSpacing.s8),
                            // Bar
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(AppRadii.small),
                                child: LinearProgressIndicator(
                                  value: acc / 100.0,
                                  minHeight: 8.0,
                                  backgroundColor: AppColors.surfaceVariant,
                                  valueColor: const AlwaysStoppedAnimation<Color>(
                                    AppColors.primary,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.s12),
                            // Accuracy percentage
                            Text(
                              '${acc.toStringAsFixed(1)}%',
                              style: AppTextStyles.caption.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.text,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.s20),

              // Model Performance Button
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48.0),
                  side: const BorderSide(color: AppColors.primary, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadii.medium),
                  ),
                ),
                onPressed: () {
                  navController.goToStep(4);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.bar_chart_rounded, size: 20.0, color: AppColors.primary),
                    const SizedBox(width: AppSpacing.s8),
                    Text(
                      'Model performance',
                      style: AppTextStyles.label.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.s8),
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s8, vertical: 2.0),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(AppRadii.small),
                  ),
                  child: Text(
                    'Research view',
                    style: AppTextStyles.caption.copyWith(
                      fontSize: 11.0,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onPrimaryContainer,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
