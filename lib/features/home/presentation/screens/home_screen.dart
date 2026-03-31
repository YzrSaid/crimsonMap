import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/custom_app_bar.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: const CustomAppBar(title: AppConstants.appName),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _WelcomeBanner(),
            const SizedBox(height: 24),
            Text('Quick Actions', style: AppTextStyles.headlineMedium),
            const SizedBox(height: 12),
            _QuickActionsGrid(),
          ],
        ),
      ),
    );
  }
}

class _WelcomeBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Welcome to', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textOnPrimary.withOpacity(0.8))),
          Text(AppConstants.university, style: AppTextStyles.headlineSmall.copyWith(color: AppColors.textOnPrimary)),
          const SizedBox(height: 8),
          Text('Where would you like to go?', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textOnPrimary.withOpacity(0.7))),
        ],
      ),
    );
  }
}

class _QuickActionsGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final actions = [
      _ActionItem(icon: Icons.explore, label: 'Explore', color: AppColors.info),
      _ActionItem(icon: Icons.qr_code_scanner, label: 'Scan QR', color: AppColors.success),
      _ActionItem(icon: Icons.view_in_ar, label: 'AR Nav', color: AppColors.primary),
      _ActionItem(icon: Icons.map_outlined, label: 'Campus Map', color: AppColors.warning),
    ];
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: actions,
    );
  }
}

class _ActionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _ActionItem({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(label, style: AppTextStyles.labelLarge),
        ],
      ),
    );
  }
}
