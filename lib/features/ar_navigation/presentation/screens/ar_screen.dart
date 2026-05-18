import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_unity_widget/flutter_unity_widget.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/services/unity_bridge_service.dart';
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
  const ArScreen({super.key});

  @override
  ConsumerState<ArScreen> createState() => _ArScreenState();
}

class _ArScreenState extends ConsumerState<ArScreen> {
  UnityWidgetController? _unityController;
  _PermState _permState = _PermState.checking;
  double _currentBearing = 0;
  bool _isNavigating = false;
  List<RouteStep> _currentSteps = [];

  @override
  void initState() {
    super.initState();
    _ensureCameraPermission();
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

  void _startSimulatedNavigation() {
    setState(() {
      _isNavigating = true;
      _currentSteps = [
        RouteStep(
          instruction: 'Walk straight ahead',
          distance: 150,
          streetName: 'Main Street',
          duration: 30,
        ),
        RouteStep(
          instruction: 'Turn right towards Building A',
          distance: 200,
          streetName: 'Academic Avenue',
          duration: 40,
        ),
        RouteStep(
          instruction: 'Enter the building and go to the left wing',
          distance: 50,
          streetName: 'Building A - Ground Floor',
          duration: 20,
        ),
      ];
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
          if (_isNavigating)
            DirectionCompass(
              bearing: _currentBearing,
              currentStreet: 'Main Street',
              nextInstruction: 'Turn right towards Building A',
              distance: 150,
            ),
          // Bottom directions card
          if (_isNavigating)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: RouteDirectionsCard(
                destination: 'Library - 2nd Floor',
                totalDistance: 400,
                totalDuration: 8,
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
                  onPressed: _startSimulatedNavigation,
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
