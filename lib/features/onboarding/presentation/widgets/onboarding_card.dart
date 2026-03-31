import 'package:flutter/material.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/onboarding_provider.dart';

class OnboardingCard extends StatelessWidget {
  final OnboardingPageData data;

  const OnboardingCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(data.imagePath, height: 280, fit: BoxFit.contain),
          const SizedBox(height: 40),
          Text(data.title, style: AppTextStyles.headlineLarge, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          Text(
            data.description,
            style: AppTextStyles.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
