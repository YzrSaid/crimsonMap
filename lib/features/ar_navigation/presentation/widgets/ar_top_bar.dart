import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class ArTopBar extends StatefulWidget {
  final VoidCallback onQrScan;
  final VoidCallback onMenuTap;

  const ArTopBar({required this.onQrScan, required this.onMenuTap, super.key});

  @override
  State<ArTopBar> createState() => _ArTopBarState();
}

class _ArTopBarState extends State<ArTopBar> {
  bool _isGpsActive = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).viewPadding.top + 12,
        left: 16,
        right: 16,
        bottom: 12,
      ),
      decoration: BoxDecoration(
        color: AppColors.overlay.withValues(alpha: 0.9),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          // GPS Status Indicator
          Container(
            decoration: BoxDecoration(
              color: AppColors.textOnPrimary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Text(
                  'GPS STATUS',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textOnPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isGpsActive ? Colors.greenAccent : Colors.redAccent,
                    boxShadow: [
                      BoxShadow(
                        color:
                            (_isGpsActive
                                    ? Colors.greenAccent
                                    : Colors.redAccent)
                                .withValues(alpha: 0.6),
                        blurRadius: 6,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          // QR Scan Button
          SizedBox(
            height: 40,
            width: 40,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onQrScan,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.textOnPrimary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.qr_code_scanner,
                    color: AppColors.textOnPrimary,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Menu Button (Three dots)
          SizedBox(
            height: 40,
            width: 40,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onMenuTap,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.textOnPrimary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.more_vert,
                    color: AppColors.textOnPrimary,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
