import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../routes/route_names.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/onboarding_card.dart';
import '../widgets/onboarding_indicator.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingProvider);
    final notifier = ref.read(onboardingProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () => context.go(RouteNames.login),
                child: const Text(AppStrings.onboardingSkip),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: state.pageController,
                onPageChanged: notifier.onPageChanged,
                itemCount: state.pages.length,
                itemBuilder: (_, index) => OnboardingCard(data: state.pages[index]),
              ),
            ),
            OnboardingIndicator(count: state.pages.length, currentIndex: state.currentPage),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ElevatedButton(
                onPressed: state.isLastPage
                    ? () => context.go(RouteNames.login)
                    : notifier.nextPage,
                child: Text(state.isLastPage ? AppStrings.onboardingGetStarted : AppStrings.onboardingNext),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
