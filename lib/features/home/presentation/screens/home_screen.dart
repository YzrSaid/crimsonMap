import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../routes/route_names.dart';
import '../providers/destination_picker_provider.dart';
import '../widgets/destination_picker_sheet.dart';
import '../widgets/home_banner_header.dart';
import '../widgets/home_map_placeholder.dart';
import '../widgets/location_status_bar.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  // y-position of the status bar from the top of the screen.
  // Smaller = higher on the banner.
  static const double _statusBarTop = 120;

  // How far the section card is pulled up into the banner (visual overlap).
  static const double _sectionCardOverlap = 18;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selection = ref.watch(homeSelectionProvider);
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
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
                        _ScanQrButton(
                          onTap: () => context.push(RouteNames.qrScanner),
                        ),
                        const SizedBox(height: 14),
                        _SectionLabel('To/Destination'),
                        const SizedBox(height: 8),
                        _DestinationField(
                          value: selection.destination?.label,
                          onTap: () => _openPicker(context),
                          onClear: selection.destination == null
                              ? null
                              : () => ref
                                  .read(homeSelectionProvider.notifier)
                                  .clearDestination(),
                        ),
                        const SizedBox(height: 14),
                        _StartNavigationButton(
                          enabled: selection.destination != null,
                          onTap: () => _startNavigation(context),
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

  void _startNavigation(BuildContext context) {
    context.push(RouteNames.ar);
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

class _ScanQrButton extends StatelessWidget {
  final VoidCallback onTap;
  const _ScanQrButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Scan a QR',
              style: AppTextStyles.buttonLarge.copyWith(color: Colors.white),
            ),
            const SizedBox(width: 12),
            const Icon(Icons.qr_code_scanner, size: 22),
          ],
        ),
      ),
    );
  }
}

class _DestinationField extends StatelessWidget {
  final String? value;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  const _DestinationField({
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
                hasValue ? value! : 'Search destination...',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.body.copyWith(
                  fontSize: 16,
                  color: hasValue
                      ? AppColors.textDark
                      : AppColors.textSecondary,
                  fontWeight:
                      hasValue ? FontWeight.w500 : FontWeight.w400,
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
