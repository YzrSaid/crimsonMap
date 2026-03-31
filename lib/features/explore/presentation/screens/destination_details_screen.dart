import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_loader.dart';
import '../../../../shared/widgets/error_state.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../data/repositories/explore_repository_impl.dart';

final _detailsProvider = FutureProvider.autoDispose.family<dynamic, String>(
  (ref, id) => ExploreRepositoryImpl().getDestinationDetails(id),
);

class DestinationDetailsScreen extends ConsumerWidget {
  final String destinationId;

  const DestinationDetailsScreen({super.key, required this.destinationId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncDetails = ref.watch(_detailsProvider(destinationId));

    return Scaffold(
      body: asyncDetails.when(
        loading: () => const AppLoader(),
        error: (e, _) => ErrorState(message: e.toString()),
        data: (destination) => CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 240,
              pinned: true,
              backgroundColor: AppColors.primary,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(destination.name, style: AppTextStyles.titleLarge.copyWith(color: AppColors.textOnPrimary)),
                background: destination.imageUrl != null
                    ? Image.network(destination.imageUrl!, fit: BoxFit.cover)
                    : Container(color: AppColors.primaryDark),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  if (destination.description != null) ...[
                    Text('About', style: AppTextStyles.headlineSmall),
                    const SizedBox(height: 8),
                    Text(destination.description!, style: AppTextStyles.bodyMedium),
                    const SizedBox(height: 24),
                  ],
                  PrimaryButton(
                    label: 'Navigate with AR',
                    icon: const Icon(Icons.view_in_ar, color: AppColors.textOnPrimary),
                    onPressed: () {},
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
