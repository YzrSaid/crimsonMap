import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/onboarding_provider.dart';

class OnboardingCard extends StatelessWidget {
  final OnboardingPageData data;

  const OnboardingCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppDimensions.screenPaddingH,
      child: Column(
        children: [
          // Illustration fills the upper portion of the available space
          Expanded(
            flex: 6,
            child: Padding(
              padding: const EdgeInsets.only(
                top: AppDimensions.space16,
                bottom: AppDimensions.space8,
              ),
              child: Image.asset(
                data.imagePath,
                fit: BoxFit.contain,
              ),
            ),
          ),

          // Title + description anchored to the lower portion
          Expanded(
            flex: 4,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  data.title,
                  style: AppTextStyles.h2.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppDimensions.space12),
                Text(
                  data.description,
                  style: AppTextStyles.body.copyWith(color: AppColors.textDark),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
