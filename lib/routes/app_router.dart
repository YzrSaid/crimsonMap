import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'route_names.dart';
import '../features/splash/presentation/screens/splash_screen.dart';
import '../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../features/navigation_shell/presentation/screens/main_navigation_screen.dart';
import '../features/home/presentation/screens/home_screen.dart';
import '../features/explore/presentation/screens/explore_screen.dart';
import '../features/explore/presentation/screens/destination_details_screen.dart';
import '../features/qr_scanner/presentation/screens/qr_scanner_screen.dart';
import '../features/ar_navigation/presentation/screens/ar_screen.dart';
import '../features/ar_navigation/presentation/screens/ar_permission_screen.dart';
import '../features/settings/presentation/screens/settings_screen.dart';

final appRouter = GoRouter(
  initialLocation: RouteNames.splash,
  debugLogDiagnostics: true,
  routes: [
    GoRoute(path: RouteNames.splash, builder: (_, _) => const SplashScreen()),
    GoRoute(
      path: RouteNames.onboarding,
      builder: (_, _) => const OnboardingScreen(),
    ),
    ShellRoute(
      builder: (context, state, child) => MainNavigationScreen(child: child),
      routes: [
        GoRoute(path: RouteNames.home, builder: (_, _) => const HomeScreen()),
        GoRoute(
          path: RouteNames.explore,
          builder: (_, _) => const ExploreScreen(),
          routes: [
            GoRoute(
              path: 'details',
              builder: (context, state) {
                final destinationId = state.extra as String;
                return DestinationDetailsScreen(destinationId: destinationId);
              },
            ),
          ],
        ),
        GoRoute(
          path: RouteNames.qrScanner,
          builder: (_, _) => const QrScannerScreen(),
        ),
        GoRoute(
          path: RouteNames.ar,
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>?;
            return ArScreen(
              selectedRoute: extra?['selectedRoute'],
              destinationLabel: extra?['destinationLabel'],
            );
          },
          routes: [
            GoRoute(
              path: 'permission',
              builder: (_, _) => const ArPermissionScreen(),
            ),
          ],
        ),
        GoRoute(
          path: RouteNames.settings,
          builder: (_, _) => const SettingsScreen(),
        ),
      ],
    ),
  ],
  errorBuilder: (context, state) =>
      Scaffold(body: Center(child: Text('Page not found: ${state.error}'))),
);
