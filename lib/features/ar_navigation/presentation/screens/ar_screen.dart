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

  Future<void> _onSpawnShape() async {
    try {
      await UnityBridgeService.spawnTestShape();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Spawn failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_permState == _PermState.checking) {
      return const Scaffold(
        body: Center(child: AppLoader()),
      );
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
                const Icon(Icons.camera_alt_outlined, size: 80, color: AppColors.primary),
                const SizedBox(height: 24),
                Text(AppStrings.arPermissionTitle,
                    style: AppTextStyles.h3, textAlign: TextAlign.center),
                const SizedBox(height: 12),
                Text(AppStrings.arPermissionBody,
                    style: AppTextStyles.bodyMedium, textAlign: TextAlign.center),
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
          Positioned(
            top: MediaQuery.of(context).viewPadding.top + 8,
            left: 8,
            child: IconButton(
              icon: const Icon(Icons.close, color: AppColors.textOnPrimary),
              style: IconButton.styleFrom(backgroundColor: AppColors.overlay),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: MediaQuery.of(context).viewPadding.bottom + 24,
            child: _SpawnShapeButton(onTap: _onSpawnShape),
          ),
        ],
      ),
    );
  }
}

class _SpawnShapeButton extends StatelessWidget {
  final VoidCallback onTap;
  const _SpawnShapeButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: const Icon(Icons.add_box_outlined),
        label: const Text('Spawn 3D Shape'),
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
    );
  }
}
