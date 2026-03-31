import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/permission_helper.dart';
import '../../../../routes/route_names.dart';
import '../../../../shared/widgets/primary_button.dart';

class ArPermissionScreen extends StatelessWidget {
  const ArPermissionScreen({super.key});

  Future<void> _requestPermission(BuildContext context) async {
    final granted = await PermissionHelper.requestCamera();
    if (granted && context.mounted) context.go(RouteNames.ar);
  }

  @override
  Widget build(BuildContext context) {
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
              Text(AppStrings.arPermissionTitle, style: AppTextStyles.h3, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              Text(AppStrings.arPermissionBody, style: AppTextStyles.bodyMedium, textAlign: TextAlign.center),
              const SizedBox(height: 40),
              PrimaryButton(
                label: 'Allow Camera Access',
                onPressed: () => _requestPermission(context),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => context.pop(),
                child: const Text('Not Now'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
