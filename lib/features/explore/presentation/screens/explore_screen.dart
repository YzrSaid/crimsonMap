import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../shared/widgets/app_loader.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_state.dart';
import '../providers/explore_provider.dart';
import '../widgets/category_chip.dart';
import '../widgets/destination_card.dart';
import '../widgets/search_bar_widget.dart';

class ExploreScreen extends ConsumerWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(exploreProvider);

    return Scaffold(
      appBar: const CustomAppBar(title: 'Explore'),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: SearchBarWidget(onChanged: ref.read(exploreProvider.notifier).search),
          ),
          const SizedBox(height: 8),
          if (state.categories.isNotEmpty)
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: state.categories.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (_, i) => CategoryChipWidget(
                  category: state.categories[i],
                  isSelected: state.selectedCategoryId == state.categories[i].id,
                  onTap: () => ref
                      .read(exploreProvider.notifier)
                      .filterByCategory(state.categories[i].id),
                ),
              ),
            ),
          const SizedBox(height: 8),
          Expanded(
            child: state.isLoading
                ? const AppLoader()
                : state.errorMessage != null
                    ? ErrorState(message: state.errorMessage!, onRetry: ref.read(exploreProvider.notifier).refresh)
                    : state.destinations.isEmpty
                        ? const EmptyState(title: AppStrings.noResults)
                        : ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: state.destinations.length,
                            separatorBuilder: (_, _) => const SizedBox(height: 12),
                            itemBuilder: (_, i) => DestinationCard(destination: state.destinations[i]),
                          ),
          ),
        ],
      ),
    );
  }
}
