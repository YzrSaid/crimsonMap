import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kOnboardingDoneKey = 'crimson_map_onboarding_complete';

/// Reads the onboarding completion flag from persistent storage.
/// Works on Android, iOS, and all Flutter desktop targets (Linux, Windows, macOS).
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
  final PageController pageController;
  final List<OnboardingPageData> pages;

  OnboardingState({
    required this.currentPage,
    required this.pageController,
    required this.pages,
  });

  bool get isLastPage => currentPage == pages.length - 1;

  OnboardingState copyWith({int? currentPage}) => OnboardingState(
        currentPage: currentPage ?? this.currentPage,
        pageController: pageController,
        pages: pages,
      );
}

class OnboardingNotifier extends Notifier<OnboardingState> {
  @override
  OnboardingState build() => OnboardingState(
        currentPage: 0,
        pageController: PageController(),
        pages: const [
          OnboardingPageData(
            title: 'Navigate the Campus',
            description:
                'Explore Western Mindanao State University with ease using an interactive campus map.',
            imagePath: 'assets/images/onboarding_1.png',
          ),
          OnboardingPageData(
            title: 'Scan & Go',
            description:
                'Scan QR codes placed around campus to instantly get directions to your destination.',
            imagePath: 'assets/images/onboarding_2.png',
          ),
          OnboardingPageData(
            title: 'AR Navigation',
            description:
                'Follow augmented reality arrows overlaid on your camera view to reach any building.',
            imagePath: 'assets/images/onboarding_3.png',
          ),
        ],
      );

  void onPageChanged(int page) => state = state.copyWith(currentPage: page);

  void nextPage() {
    state.pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  /// Persists the onboarding completion flag so the user never sees
  /// the onboarding flow again, even after a cold restart.
  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kOnboardingDoneKey, true);
  }
}

final onboardingProvider = NotifierProvider<OnboardingNotifier, OnboardingState>(
  OnboardingNotifier.new,
);
