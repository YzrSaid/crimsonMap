import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/navigation_provider.dart';
import '../../../../shared/widgets/custom_bottom_navbar.dart';
import '../../../../routes/route_names.dart';

class MainNavigationScreen extends ConsumerWidget {
  final Widget child;

  const MainNavigationScreen({super.key, required this.child});

  static const _tabs = [
    RouteNames.home,
    RouteNames.explore,
    RouteNames.qrScanner,
    RouteNames.ar,
    RouteNames.settings,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navigationProvider);

    return Scaffold(
      body: child,
      bottomNavigationBar: CustomBottomNavbar(
        currentIndex: currentIndex,
        onTap: (index) {
          ref.read(navigationProvider.notifier).setIndex(index);
          context.go(_tabs[index]);
        },
      ),
    );
  }
}
