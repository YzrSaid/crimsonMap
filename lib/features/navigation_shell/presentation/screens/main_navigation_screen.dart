import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/navigation_provider.dart';
import '../../../../shared/widgets/custom_bottom_navbar.dart';
import '../../../../routes/route_names.dart';
import '../../../home/presentation/screens/home_screen.dart';
import '../../../explore/presentation/screens/explore_screen.dart';
import '../../../settings/presentation/screens/settings_screen.dart';

class MainNavigationScreen extends ConsumerStatefulWidget {
  final Widget child;

  const MainNavigationScreen({super.key, required this.child});

  static const _tabs = [
    RouteNames.home,
    RouteNames.explore,
    RouteNames.settings,
  ];

  @override
  ConsumerState<MainNavigationScreen> createState() =>
      _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
  late final PageController _pageController;

  static const _tabPages = <Widget>[
    HomeScreen(),
    ExploreScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    final initialIndex = ref.read(navigationProvider);
    _pageController = PageController(initialPage: initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  bool get _isOnTabRoute {
    final location = GoRouterState.of(context).matchedLocation;
    return MainNavigationScreen._tabs.contains(location);
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(navigationProvider);

    ref.listen<int>(navigationProvider, (prev, next) {
      if (!_pageController.hasClients) return;
      final page = _pageController.page?.round() ?? next;
      if (page != next) {
        _pageController.animateToPage(
          next,
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeInOut,
        );
      }
    });

    return Scaffold(
      extendBody: true,
      body: _isOnTabRoute
          ? PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: _tabPages,
            )
          : widget.child,
      bottomNavigationBar: CustomBottomNavbar(
        currentIndex: currentIndex,
        onTap: (index) {
          ref.read(navigationProvider.notifier).setIndex(index);
          context.go(MainNavigationScreen._tabs[index]);
        },
      ),
    );
  }
}
