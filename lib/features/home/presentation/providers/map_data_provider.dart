import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/local_data_service.dart';
import '../../data/models/map_edge_model.dart';
import '../../data/models/map_info_model.dart';
import '../../data/models/map_node_model.dart';

final mapsListProvider = FutureProvider<List<MapInfo>>((ref) async {
  final raw = await LocalDataService.instance.maps();
  return raw.map(MapInfo.fromJson).toList();
});

final selectedMapIdProvider = StateProvider<String>((_) => 'MAP-01');

final currentMapProvider = Provider<MapInfo?>((ref) {
  final maps = ref.watch(mapsListProvider).valueOrNull;
  if (maps == null || maps.isEmpty) return null;
  final id = ref.watch(selectedMapIdProvider);
  for (final m in maps) {
    if (m.mapId == id) return m;
  }
  return maps.first;
});

final currentMapNodesProvider = FutureProvider<List<MapNode>>((ref) async {
  final mapId = ref.watch(selectedMapIdProvider);
  final raw = await LocalDataService.instance.nodes(mapId);
  return raw
      .map(MapNode.fromJson)
      .where((n) => n.isActive && n.hasCoordinates)
      .toList();
});

final currentMapEdgesProvider = FutureProvider<List<MapEdge>>((ref) async {
  final mapId = ref.watch(selectedMapIdProvider);
  final raw = await LocalDataService.instance.loadJsonArray('edges_$mapId.json');
  return raw.map(MapEdge.fromJson).where((e) => e.isActive).toList();
});

final infraAcronymsProvider = FutureProvider<Map<String, String>>((ref) async {
  final raw = await LocalDataService.instance.infrastructure();
  final out = <String, String>{};
  for (final m in raw) {
    final id = (m['infra_id'] as String?)?.trim();
    if (id == null || id.isEmpty) continue;
    final acronym = (m['acronym'] as String?)?.trim();
    final name = (m['name'] as String?)?.trim();
    if (acronym != null && acronym.isNotEmpty) {
      out[id] = acronym;
    } else if (name != null && name.isNotEmpty) {
      out[id] = name;
    }
  }
  return out;
});
