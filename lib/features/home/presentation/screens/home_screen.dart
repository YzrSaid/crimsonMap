import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../routes/route_names.dart';
import '../providers/destination_picker_provider.dart';
import '../widgets/destination_picker_sheet.dart';
import '../widgets/from_location_picker_sheet.dart';
import '../widgets/home_banner_header.dart';
import '../widgets/home_map_placeholder.dart';
import '../widgets/location_status_bar.dart';
import '../widgets/routes_modal.dart';
import '../../../../core/services/pathfinding_service.dart' as pathfinding;
import '../providers/map_data_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  pathfinding.Route? _selectedRoute;

  // y-position of the status bar from the top of the screen.
  // Smaller = higher on the banner.
  static const double _statusBarTop = 120;

  // How far the section card is pulled up into the banner (visual overlap).
  static const double _sectionCardOverlap = 18;

  @override
  Widget build(BuildContext context) {
    final ref = this.ref;
    final selection = ref.watch(homeSelectionProvider);
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.4),
          width: 2,
        ),
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              children: [
                HomeBannerHeader(onAboutTap: () => _showAbout(context)),
                Transform.translate(
                  offset: const Offset(0, -_sectionCardOverlap),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _SectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SectionLabel('Where are you now?'),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: _FromLocationField(
                                  value: selection.fromLocation?.label,
                                  onTap: () => _openFromPicker(context),
                                  onClear: selection.fromLocation == null
                                      ? null
                                      : () => ref
                                            .read(
                                              homeSelectionProvider.notifier,
                                            )
                                            .clearFromLocation(),
                                ),
                              ),
                              const SizedBox(width: 8),
                              _ScanQrButton(
                                onTap: () => context.push(RouteNames.qrScanner),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          _SectionLabel('To/Destination'),
                          const SizedBox(height: 8),
                          _DestinationField(
                            value: selection.destination?.label,
                            enabled: selection.fromLocation != null,
                            onTap: () => _openPicker(context),
                            onClear: selection.destination == null
                                ? null
                                : () => ref
                                      .read(homeSelectionProvider.notifier)
                                      .clearDestination(),
                          ),
                          const SizedBox(height: 14),
                          _StartNavigationButton(
                            enabled: selection.hasValidRoute,
                            onTap: () => _startNavigation(context, ref),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const Expanded(child: HomeMapPlaceholder()),
              ],
            ),
            Positioned(
              top: _statusBarTop,
              left: 0,
              right: 0,
              child: Center(
                child: SizedBox(
                  width: screenWidth * 0.55,
                  child: const LocationStatusBar(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openFromPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const FromLocationPickerSheet(),
    );
  }

  void _openPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const DestinationPickerSheet(),
    );
  }

  Future<void> _startNavigation(BuildContext context, WidgetRef ref) async {
    // show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final selection = ref.read(homeSelectionProvider);

    // Load current map nodes and edges
    final nodes = await ref.read(currentMapNodesProvider.future);
    final edges = await ref.read(currentMapEdgesProvider.future);

    // Map to pathfinding nodes
    final nodeMap = <String, pathfinding.PathNode>{};
    for (final n in nodes) {
      final lat = n.latitude ?? 0.0;
      final lon = n.longitude ?? 0.0;
      nodeMap[n.nodeId] = pathfinding.PathNode(
        nodeId: n.nodeId,
        name: n.name,
        type: n.type.toString().split('.').last == 'infrastructure'
            ? 'infrastructure'
            : (n.type.toString().split('.').last == 'intermediate'
                  ? 'intermediate'
                  : 'pathway'),
        campusId: n.campusId,
        latitude: lat,
        longitude: lon,
        xCoordinate: lat,
        yCoordinate: lon,
        isActive: n.isActive,
      );
    }

    // helper to compute distance meters between two coords
    double _distanceMeters(double lat1, double lon1, double lat2, double lon2) {
      const R = 6371000; // earth meters
      final dLat = (lat2 - lat1) * (pi / 180);
      final dLon = (lon2 - lon1) * (pi / 180);
      final a =
          sin(dLat / 2) * sin(dLat / 2) +
          cos(lat1 * (pi / 180)) *
              cos(lat2 * (pi / 180)) *
              sin(dLon / 2) *
              sin(dLon / 2);
      final c = 2 * atan2(sqrt(a), sqrt(1 - a));
      return R * c;
    }

    final edgeList = <pathfinding.PathEdge>[];
    for (final e in edges) {
      final from = nodeMap[e.fromNodeId];
      final to = nodeMap[e.toNodeId];
      if (from == null || to == null) continue;
      final dist = _distanceMeters(
        from.latitude,
        from.longitude,
        to.latitude,
        to.longitude,
      );
      edgeList.add(
        pathfinding.PathEdge(
          fromNodeId: e.fromNodeId,
          toNodeId: e.toNodeId,
          distance: dist,
          pathType: e.pathType.isNotEmpty ? e.pathType : 'via_walkway',
          isActive: e.isActive,
        ),
      );
    }

    final service = pathfinding.PathfindingService();
    service.initializeGraph(nodes: nodeMap.values.toList(), edges: edgeList);

    // determine start/end node ids
    String? startNodeId;
    String? endNodeId;

    // If roomId specified, prefer node with related_room_id
    final fromSel = selection.fromLocation;
    final toSel = selection.destination;
    if (fromSel == null || toSel == null) {
      Navigator.of(context).pop();
      return;
    }

    // helpers to find nodes
    String? findNodeForRoom(String roomId) {
      for (final n in nodes) {
        if ((n.relatedRoomId ?? '') == roomId) return n.nodeId;
      }
      return null;
    }

    String? findNodeForInfra(String infraId) {
      for (final n in nodes) {
        if ((n.relatedInfraId ?? '') == infraId) return n.nodeId;
      }
      return null;
    }

    // find node for start
    if (fromSel.roomId != null && fromSel.roomId!.isNotEmpty) {
      startNodeId = findNodeForRoom(fromSel.roomId!);
    }
    // fallback: find a node with matching infra
    startNodeId ??= findNodeForInfra(fromSel.infraId);

    // find node for destination
    if (toSel.roomId != null && toSel.roomId!.isNotEmpty) {
      endNodeId = findNodeForRoom(toSel.roomId!);
    }
    endNodeId ??= findNodeForInfra(toSel.infraId);

    // close loading
    Navigator.of(context).pop();

    if (startNodeId == null || endNodeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to resolve start or end nodes for routing.'),
        ),
      );
      return;
    }

    final routes = await service.findMultiplePaths(
      startNodeId: startNodeId,
      endNodeId: endNodeId,
      maxPaths: 3,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => RoutesModal(
        routes: routes,
        destinationLabel: selection.destination?.label,
        onRouteSelected: (route) {
          setState(() {
            _selectedRoute = route;
          });
        },
        onNavigate: () {
          if (_selectedRoute != null) {
            Navigator.pop(modalContext); // Close modal first
            context.push(
              RouteNames.ar,
              extra: {
                'selectedRoute': _selectedRoute,
                'destinationLabel': selection.destination?.label,
              },
            );
          }
        },
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('About Crimson Map'),
        content: const Text(
          'WMSU campus navigation app. Pick a destination, scan a QR to '
          'confirm your location, and start navigating.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final Widget child;
  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w700),
    );
  }
}

class _FromLocationField extends StatelessWidget {
  final String? value;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  const _FromLocationField({
    required this.value,
    required this.onTap,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final hasValue = value != null && value!.isNotEmpty;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF2F2F2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                hasValue ? value! : 'Where are you?',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.body.copyWith(
                  fontSize: 16,
                  color: hasValue
                      ? AppColors.textDark
                      : AppColors.textSecondary,
                  fontWeight: hasValue ? FontWeight.w500 : FontWeight.w400,
                ),
              ),
            ),
            if (onClear != null)
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: onClear,
              )
            else
              const Icon(Icons.expand_more, color: AppColors.textDark),
          ],
        ),
      ),
    );
  }
}

class _ScanQrButton extends StatelessWidget {
  final VoidCallback onTap;
  const _ScanQrButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      width: 52,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: const Icon(Icons.qr_code_scanner, size: 24),
      ),
    );
  }
}

class _DestinationField extends StatelessWidget {
  final String? value;
  final bool enabled;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  const _DestinationField({
    required this.value,
    this.enabled = true,
    required this.onTap,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final hasValue = value != null && value!.isNotEmpty;
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: enabled
              ? const Color(0xFFF2F2F2)
              : AppColors.textSecondary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                hasValue
                    ? value!
                    : (enabled ? 'Search destination...' : 'Select FROM first'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.body.copyWith(
                  fontSize: 16,
                  color: enabled
                      ? (hasValue
                            ? AppColors.textDark
                            : AppColors.textSecondary)
                      : AppColors.textSecondary.withValues(alpha: 0.5),
                  fontWeight: hasValue ? FontWeight.w500 : FontWeight.w400,
                ),
              ),
            ),
            if (onClear != null)
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: onClear,
              )
            else
              Icon(
                Icons.expand_more,
                color: enabled
                    ? AppColors.textDark
                    : AppColors.textSecondary.withValues(alpha: 0.5),
              ),
          ],
        ),
      ),
    );
  }
}

class _StartNavigationButton extends StatelessWidget {
  final bool enabled;
  final VoidCallback onTap;

  const _StartNavigationButton({required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: enabled ? onTap : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.4),
          disabledForegroundColor: AppColors.textOnPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
          'Start Navigation',
          style: AppTextStyles.buttonLarge.copyWith(
            color: AppColors.textOnPrimary,
          ),
        ),
      ),
    );
  }
}
