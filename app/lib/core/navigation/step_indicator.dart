import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Step indicator matching docs/designs/Design Tokens.png:
/// "Step indicator: 8 px (line) + 4 px (dots)"
class StepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const StepIndicator({
    super.key,
    required this.currentStep,
    this.totalSteps = 4,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(totalSteps, (index) {
        final stepNumber = index + 1;
        final isActive = stepNumber == currentStep;
        final isCompleted = stepNumber < currentStep;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.s4),
          width: isActive ? 24.0 : 8.0,
          height: AppSpacing.stepIndicatorLine,
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.primary
                : isCompleted
                    ? AppColors.primary.withValues(alpha: 0.4)
                    : AppColors.border,
            borderRadius: AppRadii.brExtraSmall,
          ),
        );
      }),
    );
  }
}

