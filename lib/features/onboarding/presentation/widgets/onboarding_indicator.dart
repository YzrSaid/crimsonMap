import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../../core/theme/app_colors.dart';

class OnboardingIndicator extends StatelessWidget {
  final PageController controller;
  final int count;

  const OnboardingIndicator({
    super.key,
    required this.controller,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return SmoothPageIndicator(
      controller: controller,
      count: count,
      effect: const WormEffect(
        dotHeight: 8,
        dotWidth: 8,
        spacing: 8,
        activeDotColor: AppColors.primary,
        dotColor: AppColors.muted,
      ),
    );
  }
}
