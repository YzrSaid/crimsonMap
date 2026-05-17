import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/local_data_service.dart';

class BuildingOption {
  final String infraId;
  final String name;
  final String? acronym;
  final List<RoomOption> rooms;

  const BuildingOption({
    required this.infraId,
    required this.name,
    required this.acronym,
    required this.rooms,
  });
}

class RoomOption {
  final String roomId;
  final String name;
  final String infraId;
  final String indoorType;

  const RoomOption({
    required this.roomId,
    required this.name,
    required this.infraId,
    required this.indoorType,
  });
}

final buildingsWithRoomsProvider = FutureProvider<List<BuildingOption>>((ref) async {
  final data = LocalDataService.instance;
  final infra = await data.infrastructure();
  final indoor = await data.loadJsonArray('indoor.json');

  final roomsByInfra = <String, List<RoomOption>>{};
  for (final row in indoor) {
    if (row['is_deleted'] == true) continue;
    final infraId = row['infra_id'] as String?;
    if (infraId == null) continue;
    final indoorType = (row['indoor_type'] as String?) ?? 'room';
    if (indoorType != 'room') continue;
    roomsByInfra
        .putIfAbsent(infraId, () => [])
        .add(RoomOption(
          roomId: row['room_id'] as String? ?? '',
          name: row['name'] as String? ?? '',
          infraId: infraId,
          indoorType: indoorType,
        ));
  }

  final buildings = infra
      .where((r) => r['is_deleted'] != true)
      .map((r) {
        final infraId = r['infra_id'] as String? ?? '';
        final rooms = List<RoomOption>.from(roomsByInfra[infraId] ?? const [])
          ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        return BuildingOption(
          infraId: infraId,
          name: r['name'] as String? ?? '',
          acronym: r['acronym'] as String?,
          rooms: rooms,
        );
      })
      .where((b) => b.infraId.isNotEmpty && b.name.isNotEmpty)
      .toList()
    ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

  return buildings;
});

class DestinationSelection {
  final String label;
  final String infraId;
  final String? roomId;

  const DestinationSelection({
    required this.label,
    required this.infraId,
    this.roomId,
  });
}

class HomeSelectionState {
  final DestinationSelection? destination;
  final String currentBuildingName;
  final GpsStatus gpsStatus;
  final bool locked;

  const HomeSelectionState({
    this.destination,
    this.currentBuildingName = 'Searching for location...',
    this.gpsStatus = GpsStatus.searching,
    this.locked = false,
  });

  HomeSelectionState copyWith({
    DestinationSelection? destination,
    String? currentBuildingName,
    GpsStatus? gpsStatus,
    bool? locked,
    bool clearDestination = false,
  }) {
    return HomeSelectionState(
      destination: clearDestination ? null : (destination ?? this.destination),
      currentBuildingName: currentBuildingName ?? this.currentBuildingName,
      gpsStatus: gpsStatus ?? this.gpsStatus,
      locked: locked ?? this.locked,
    );
  }
}

enum GpsStatus { strong, weak, none, searching }

class HomeSelectionNotifier extends Notifier<HomeSelectionState> {
  @override
  HomeSelectionState build() => const HomeSelectionState();

  void selectDestination(DestinationSelection selection) {
    state = state.copyWith(destination: selection);
  }

  void clearDestination() {
    state = state.copyWith(clearDestination: true);
  }

  void toggleLock() {
    state = state.copyWith(locked: !state.locked);
  }
}

final homeSelectionProvider =
    NotifierProvider<HomeSelectionNotifier, HomeSelectionState>(
  HomeSelectionNotifier.new,
);
