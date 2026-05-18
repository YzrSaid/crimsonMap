import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_unity_widget/flutter_unity_widget.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/services/unity_bridge_service.dart';
import '../../../../core/services/pathfinding_service.dart' as pathfinding;
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/permission_helper.dart';
import '../../../../shared/widgets/app_loader.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../widgets/ar_top_bar.dart';
import '../widgets/direction_compass.dart';
import '../widgets/route_directions_card.dart';
import '../widgets/ar_menu_sheet.dart';

// Unity expects the camera permission to already be granted before its AR
// scene mounts (unityplayer.SkipPermissionsDialog=true in the manifest).
// If we mount the UnityWidget without permission, ARCore reports
// "AR not supported" and the activity crashes.
enum _PermState { checking, granted, denied, permanentlyDenied }

class ArScreen extends ConsumerStatefulWidget {
  final pathfinding.Route? selectedRoute;
  final String? destinationLabel;

  const ArScreen({this.selectedRoute, this.destinationLabel, super.key});

  @override
  ConsumerState<ArScreen> createState() => _ArScreenState();
}

class _ArScreenState extends ConsumerState<ArScreen> {
  UnityWidgetController? _unityController;
  _PermState _permState = _PermState.checking;
  double _currentBearing = 0;
  bool _isNavigating = false;
  List<RouteStep> _currentSteps = [];
  late String _destinationName;
  late double _totalDistance;
  late int _totalDuration;

  @override
  void initState() {
    super.initState();
    _ensureCameraPermission();
    _initializeRouteData();
  }

  void _initializeRouteData() {
    if (widget.selectedRoute != null) {
      _destinationName =
          widget.destinationLabel ?? widget.selectedRoute!.endNode.name;
      _totalDistance = widget.selectedRoute!.totalDistance;
      _totalDuration = widget.selectedRoute!.walkingTime.toInt();
      _generateRouteSteps();
      // Auto-start navigation when route is provided
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && widget.selectedRoute != null) {
          setState(() {
            _isNavigating = true;
          });
        }
      });
    } else {
      _destinationName = 'Destination';
      _totalDistance = 0;
      _totalDuration = 0;
    }
  }

  void _generateRouteSteps() {
    _currentSteps = [];
    final path = widget.selectedRoute?.path ?? [];

    for (int i = 0; i < path.length - 1; i++) {
      final current = path[i];
      final next = path[i + 1];

      // Calculate distance between consecutive nodes
      final distance = _calculateNodeDistance(current, next);

      // Determine instruction based on node type
      final instruction = _generateInstruction(current, next, i, path.length);

      _currentSteps.add(
        RouteStep(
          instruction: instruction,
          distance: distance,
          streetName: current.name,
          duration: (distance / 1.4).toInt(), // ~1.4 m/s average walking speed
        ),
      );
    }
  }

  double _calculateNodeDistance(
    pathfinding.PathNode from,
    pathfinding.PathNode to,
  ) {
    const R = 6371000; // Earth radius in meters
    final dLat = (to.latitude - from.latitude) * (3.14159 / 180);
    final dLon = (to.longitude - from.longitude) * (3.14159 / 180);
    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(from.latitude * (3.14159 / 180)) *
            cos(to.latitude * (3.14159 / 180)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  String _generateInstruction(
    pathfinding.PathNode current,
    pathfinding.PathNode next,
    int stepIndex,
    int totalSteps,
  ) {
    if (stepIndex == 0) {
      return 'Start heading towards ${next.name}';
    }
    if (stepIndex == totalSteps - 2) {
      return 'Arrive at your destination';
    }

    final nodeType = current.type;
    if (nodeType == 'infrastructure') {
      return 'Continue through ${current.name}';
    } else if (nodeType == 'intermediate') {
      return 'Pass through ${current.name} and continue';
    }

    return 'Continue straight ahead';
  }

  @override
  void dispose() {
    UnityBridgeService.detachController();
    _unityController?.dispose();
    super.dispose();
  }

  Future<void> _ensureCameraPermission() async {
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      status = await Permission.camera.request();
    }
    if (!mounted) return;
    setState(() {
      if (status.isGranted) {
        _permState = _PermState.granted;
      } else if (status.isPermanentlyDenied) {
        _permState = _PermState.permanentlyDenied;
      } else {
        _permState = _PermState.denied;
      }
    });
  }

  void _showMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => ArMenuSheet(
        onSettings: () {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Settings opened')));
        },
        onStopNavigation: () {
          setState(() {
            _isNavigating = false;
          });
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Navigation stopped')));
        },
        onReportIssue: () {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Issue reported')));
        },
      ),
    );
  }

  void _startNavigation() {
    if (widget.selectedRoute == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No route selected')));
      return;
    }
    setState(() {
      _isNavigating = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_permState == _PermState.checking) {
      return const Scaffold(body: Center(child: AppLoader()));
    }
    if (_permState != _PermState.granted) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.camera_alt_outlined,
                  size: 80,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 24),
                Text(
                  AppStrings.arPermissionTitle,
                  style: AppTextStyles.h3,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  AppStrings.arPermissionBody,
                  style: AppTextStyles.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                PrimaryButton(
                  label: _permState == _PermState.permanentlyDenied
                      ? 'Open App Settings'
                      : 'Allow Camera Access',
                  onPressed: _permState == _PermState.permanentlyDenied
                      ? () async {
                          await PermissionHelper.openAppSettings();
                          await _ensureCameraPermission();
                        }
                      : _ensureCameraPermission,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          UnityWidget(
            onUnityCreated: (controller) {
              _unityController = controller;
              UnityBridgeService.attachController(controller);
            },
            onUnityMessage: UnityBridgeService.dispatchIncoming,
            useAndroidViewSurface: true,
          ),
          // Top Bar with GPS status and menu
          ArTopBar(
            onQrScan: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('QR Scanner opened')),
              );
            },
            onMenuTap: _showMenu,
          ),
          // Center compass when navigating
          if (_isNavigating && _currentSteps.isNotEmpty)
            DirectionCompass(
              bearing: _currentBearing,
              currentStreet: _currentSteps[0].streetName,
              nextInstruction: _currentSteps[0].instruction,
              distance: _currentSteps[0].distance,
            ),
          // Bottom directions card
          if (_isNavigating && _currentSteps.isNotEmpty)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: RouteDirectionsCard(
                destination: _destinationName,
                totalDistance: _totalDistance,
                totalDuration: _totalDuration,
                steps: _currentSteps,
                onCancelRoute: () {
                  setState(() {
                    _isNavigating = false;
                  });
                },
              ),
            )
          else
            // Start navigation button when not navigating
            Positioned(
              left: 16,
              right: 16,
              bottom: MediaQuery.of(context).viewPadding.bottom + 24,
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _startNavigation,
                  icon: const Icon(Icons.navigation),
                  label: const Text('Start Navigation'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textOnPrimary,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    textStyle: AppTextStyles.buttonLarge,
                  ),
                ),
              ),
            ),
          // Close button
          Positioned(
            top: MediaQuery.of(context).viewPadding.top + 8,
            left: 8,
            child: IconButton(
              icon: const Icon(Icons.close, color: AppColors.textOnPrimary),
              style: IconButton.styleFrom(backgroundColor: AppColors.overlay),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ),
        ],
      ),
    );
  }
}
