import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_assets.dart';

const _kOnboardingDoneKey = 'crimson_map_onboarding_complete';

Future<bool> isOnboardingComplete() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool(_kOnboardingDoneKey) ?? false;
}

class OnboardingPageData {
  final String title;
  final String description;
  final String imagePath;

  const OnboardingPageData({
    required this.title,
    required this.description,
    required this.imagePath,
  });
}

class OnboardingState {
  final int currentPage;
  final List<OnboardingPageData> pages;

  const OnboardingState({
    required this.currentPage,
    required this.pages,
  });

  bool get isLastPage => currentPage == pages.length - 1;

  OnboardingState copyWith({int? currentPage}) => OnboardingState(
        currentPage: currentPage ?? this.currentPage,
        pages: pages,
      );
}

class OnboardingNotifier extends Notifier<OnboardingState> {
  @override
  OnboardingState build() => const OnboardingState(
        currentPage: 0,
        pages: [
          OnboardingPageData(
            title: 'Welcome!',
            description:
                'Hello, Crimsons! Welcome to CrimsonMap, the official AR mobile app for WMSU.',
            imagePath: AppAssets.onboarding1,
          ),
          OnboardingPageData(
            title: 'Navigate with Confidence!',
            description:
                'Navigate your campus with confidence. Find buildings, explore routes, and never get lost again!',
            imagePath: AppAssets.onboarding2,
          ),
          OnboardingPageData(
            title: 'Explore Smarter!',
            description:
                'Discover key spots around campus, from classrooms to offices with smart path recommendations.',
            imagePath: AppAssets.onboarding3,
          ),
          OnboardingPageData(
            title: "Let's Get Started!",
            description:
                'Join your fellow students using CrimsonMap to explore WMSU. Tap below to start your journey!',
            imagePath: AppAssets.onboarding4,
          ),
        ],
      );

  void setPage(int page) => state = state.copyWith(currentPage: page);

  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kOnboardingDoneKey, true);
  }
}

final onboardingProvider = NotifierProvider<OnboardingNotifier, OnboardingState>(
  OnboardingNotifier.new,
);
