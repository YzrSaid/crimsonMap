import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../routes/route_names.dart';
import '../../domain/entities/destination.dart';

class DestinationCard extends StatelessWidget {
  final Destination destination;

  const DestinationCard({super.key, required this.destination});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go(RouteNames.destinationDetails, extra: destination.id),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
              child: destination.imageUrl != null
                  ? Image.network(destination.imageUrl!, width: 90, height: 90, fit: BoxFit.cover)
                  : Container(width: 90, height: 90, color: AppColors.primaryLight, child: const Icon(Icons.place, color: AppColors.textOnPrimary, size: 32)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(destination.name, style: AppTextStyles.titleLarge, maxLines: 1, overflow: TextOverflow.ellipsis),
                    if (destination.description != null) ...[
                      const SizedBox(height: 4),
                      Text(destination.description!, style: AppTextStyles.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                    ],
                    if (destination.floor != null) ...[
                      const SizedBox(height: 4),
                      Text('Floor ${destination.floor}', style: AppTextStyles.caption),
                    ],
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(right: 8),
              child: Icon(Icons.chevron_right, color: AppColors.textDisabled),
            ),
          ],
        ),
      ),
    );
  }
}
