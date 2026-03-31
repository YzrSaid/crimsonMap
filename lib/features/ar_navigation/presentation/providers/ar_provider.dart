import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/ar_navigation_repository_impl.dart';
import '../../domain/entities/route_path.dart';
import '../../integration/ar_payload_builder.dart';
import '../../../../core/services/unity_bridge_service.dart';
import '../../../../core/services/location_service.dart';

enum ArStatus { idle, loadingRoute, calibrating, navigating, error }

class ArState {
  final ArStatus status;
  final RoutePath? currentRoute;
  final String? destinationId;
  final String? errorMessage;

  const ArState({
    this.status = ArStatus.idle,
    this.currentRoute,
    this.destinationId,
    this.errorMessage,
  });

  ArState copyWith({
    ArStatus? status,
    RoutePath? currentRoute,
    String? destinationId,
    String? errorMessage,
  }) =>
      ArState(
        status: status ?? this.status,
        currentRoute: currentRoute ?? this.currentRoute,
        destinationId: destinationId ?? this.destinationId,
        errorMessage: errorMessage,
      );
}

class ArNotifier extends Notifier<ArState> {
  @override
  ArState build() => const ArState();

  Future<void> startNavigation(String destinationId) async {
    state = state.copyWith(status: ArStatus.loadingRoute, destinationId: destinationId);
    try {
      final position = await LocationService.getCurrentPosition();
      if (position == null) throw Exception('Could not get current location.');

      final repo = ArNavigationRepositoryImpl();
      final route = await repo.getArRoute(
        destinationId: destinationId,
        userLatitude: position.latitude,
        userLongitude: position.longitude,
      );

      state = state.copyWith(status: ArStatus.calibrating, currentRoute: route);

      final payload = ArPayloadBuilder.build(route);
      await UnityBridgeService.startNavigation(payload);

      state = state.copyWith(status: ArStatus.navigating);
    } catch (e) {
      state = state.copyWith(status: ArStatus.error, errorMessage: e.toString());
    }
  }

  Future<void> stopNavigation() async {
    await UnityBridgeService.stopNavigation();
    state = const ArState();
  }
}

final arProvider = NotifierProvider<ArNotifier, ArState>(ArNotifier.new);
