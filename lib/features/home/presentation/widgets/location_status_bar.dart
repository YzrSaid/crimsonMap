import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/destination_picker_provider.dart';

class LocationStatusBar extends ConsumerWidget {
  const LocationStatusBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeSelectionProvider);

    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(999),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _GpsDot(status: state.gpsStatus),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              state.currentBuildingName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.w500,
                color: AppColors.textDark,
              ),
            ),
          ),
          InkWell(
            onTap: () =>
                ref.read(homeSelectionProvider.notifier).toggleLock(),
            borderRadius: BorderRadius.circular(999),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Icon(
                state.locked ? Icons.lock : Icons.lock_open,
                size: 20,
                color: AppColors.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GpsDot extends StatelessWidget {
  final GpsStatus status;

  const _GpsDot({required this.status});

  Color get _color {
    switch (status) {
      case GpsStatus.strong:
        return AppColors.success;
      case GpsStatus.weak:
        return AppColors.warning;
      case GpsStatus.none:
        return AppColors.error;
      case GpsStatus.searching:
        return AppColors.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        color: _color,
        shape: BoxShape.circle,
      ),
    );
  }
}
