import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeState {
  const HomeState();
}

class HomeNotifier extends Notifier<HomeState> {
  @override
  HomeState build() => const HomeState();
}

final homeProvider = NotifierProvider<HomeNotifier, HomeState>(HomeNotifier.new);
