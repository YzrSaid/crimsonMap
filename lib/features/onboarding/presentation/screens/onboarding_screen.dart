import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../routes/route_names.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/onboarding_card.dart';
import '../widgets/onboarding_indicator.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  late final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _next() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _finish() async {
    await ref.read(onboardingProvider.notifier).completeOnboarding();
    if (mounted) context.go(RouteNames.home);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingProvider);
    final notifier = ref.read(onboardingProvider.notifier);
    final screenH = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        children: [
          // ── Shared campus banner (fixed, does not slide) ─────────────────
          _BannerHeader(height: screenH * 0.28),

          // ── Sliding page content ─────────────────────────────────────────
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: notifier.setPage,
              itemCount: state.pages.length,
              itemBuilder: (_, i) => OnboardingCard(data: state.pages[i]),
            ),
          ),

          // ── Bottom navigation ────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppDimensions.space24,
              vertical: AppDimensions.space8,
            ),
            child: state.isLastPage
                ? _LastPageNav(
                    controller: _pageController,
                    count: state.pages.length,
                    onFinish: _finish,
                  )
                : _DefaultNav(
                    controller: _pageController,
                    count: state.pages.length,
                    onSkip: _finish,
                    onNext: _next,
                  ),
          ),

          SizedBox(height: AppDimensions.space24),
        ],
      ),
    );
  }
}

// ── Banner ──────────────────────────────────────────────────────────────────

class _BannerHeader extends StatelessWidget {
  final double height;

  const _BannerHeader({required this.height});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Campus photo
          Image.asset(AppAssets.onboardingBanner, fit: BoxFit.cover),

          // White overlay — lightens the image to ~0.4 visible intensity
          Container(color: Colors.white.withValues(alpha: 0.6)),
        ],
      ),
    );
  }
}

// ── Navigation: pages 0–2 ───────────────────────────────────────────────────

class _DefaultNav extends StatelessWidget {
  final PageController controller;
  final int count;
  final VoidCallback onSkip;
  final VoidCallback onNext;

  const _DefaultNav({
    required this.controller,
    required this.count,
    required this.onSkip,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
          onPressed: onSkip,
          child: Text(
            AppStrings.onboardingSkip,
            style: AppTextStyles.buttonMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        OnboardingIndicator(controller: controller, count: count),
        TextButton(
          onPressed: onNext,
          child: Text(
            AppStrings.onboardingNext,
            style: AppTextStyles.buttonMedium.copyWith(
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Navigation: last page ───────────────────────────────────────────────────

class _LastPageNav extends StatelessWidget {
  final PageController controller;
  final int count;
  final VoidCallback onFinish;

  const _LastPageNav({
    required this.controller,
    required this.count,
    required this.onFinish,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        OnboardingIndicator(controller: controller, count: count),
        SizedBox(height: AppDimensions.space24),
        SizedBox(
          width: double.infinity,
          height: AppDimensions.buttonHeightLg,
          child: ElevatedButton(
            onPressed: onFinish,
            child: Text(AppStrings.onboardingGetStarted),
          ),
        ),
      ],
    );
  }
}
