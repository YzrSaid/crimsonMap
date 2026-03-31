import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/explore_repository_impl.dart';
import '../../domain/entities/destination.dart';
import '../../domain/entities/category.dart';

class ExploreState {
  final List<Destination> destinations;
  final List<Category> categories;
  final String? selectedCategoryId;
  final String searchQuery;
  final bool isLoading;
  final String? errorMessage;

  const ExploreState({
    this.destinations = const [],
    this.categories = const [],
    this.selectedCategoryId,
    this.searchQuery = '',
    this.isLoading = false,
    this.errorMessage,
  });

  ExploreState copyWith({
    List<Destination>? destinations,
    List<Category>? categories,
    String? selectedCategoryId,
    String? searchQuery,
    bool? isLoading,
    String? errorMessage,
  }) =>
      ExploreState(
        destinations: destinations ?? this.destinations,
        categories: categories ?? this.categories,
        selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
        searchQuery: searchQuery ?? this.searchQuery,
        isLoading: isLoading ?? this.isLoading,
        errorMessage: errorMessage,
      );
}

class ExploreNotifier extends Notifier<ExploreState> {
  @override
  ExploreState build() {
    _load();
    return const ExploreState(isLoading: true);
  }

  Future<void> _load() async {
    try {
      final repo = ExploreRepositoryImpl();
      final results = await Future.wait([repo.getDestinations(), repo.getCategories()]);
      state = state.copyWith(
        destinations: results[0] as List<Destination>,
        categories: results[1] as List<Category>,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> search(String query) async {
    state = state.copyWith(searchQuery: query, isLoading: true);
    try {
      final repo = ExploreRepositoryImpl();
      final results = await repo.searchDestinations(query);
      state = state.copyWith(destinations: results, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void filterByCategory(String? categoryId) =>
      state = state.copyWith(selectedCategoryId: categoryId);

  Future<void> refresh() => _load();
}

final exploreProvider = NotifierProvider<ExploreNotifier, ExploreState>(ExploreNotifier.new);
