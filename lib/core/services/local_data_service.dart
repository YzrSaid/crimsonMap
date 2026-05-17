import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

// Loads campus catalog data from bundled JSON in assets/data/.
// Files are read once on first access and cached for the app lifetime.
//
// Same files Unity reads from StreamingAssets — both sides stay in sync as
// long as the export step copies updated JSON into both locations.
class LocalDataService {
  LocalDataService._();
  static final LocalDataService instance = LocalDataService._();

  final Map<String, dynamic> _cache = {};

  Future<List<Map<String, dynamic>>> loadJsonArray(String fileName) async {
    if (_cache.containsKey(fileName)) {
      return (_cache[fileName] as List).cast<Map<String, dynamic>>();
    }
    final raw = await rootBundle.loadString('assets/data/$fileName');
    final decoded = jsonDecode(raw);
    if (decoded is! List) {
      throw FormatException('Expected JSON array in $fileName, got ${decoded.runtimeType}');
    }
    final list = decoded.cast<Map<String, dynamic>>();
    _cache[fileName] = list;
    return list;
  }

  Future<List<Map<String, dynamic>>> categories() => loadJsonArray('categories.json');
  Future<List<Map<String, dynamic>>> infrastructure() => loadJsonArray('infrastructure.json');
  Future<List<Map<String, dynamic>>> maps() => loadJsonArray('maps.json');
  Future<List<Map<String, dynamic>>> campus() => loadJsonArray('campus.json');

  // Map-specific files (nodes_MAP-01.json, nodes_MAP-02.json, etc.).
  Future<List<Map<String, dynamic>>> nodes(String mapId) =>
      loadJsonArray('nodes_$mapId.json');

  // Returns all infrastructure nodes across every map, indexed by infra_id.
  // Used to join infrastructure metadata with its coordinates.
  Future<Map<String, Map<String, dynamic>>> infraNodesByInfraId() async {
    final cached = _cache['__infra_nodes_by_id__'];
    if (cached != null) return Map<String, Map<String, dynamic>>.from(cached);

    final allMaps = await maps();
    final result = <String, Map<String, dynamic>>{};
    for (final m in allMaps) {
      final mapId = m['map_id'] as String?;
      if (mapId == null) continue;
      try {
        final nodesForMap = await nodes(mapId);
        for (final n in nodesForMap) {
          if (n['type'] != 'infrastructure') continue;
          final infraId = n['related_infra_id'] as String?;
          if (infraId == null || infraId.isEmpty) continue;
          // First node wins if duplicates exist across maps.
          result.putIfAbsent(infraId, () => n);
        }
      } catch (_) {
        // Missing map nodes file — skip silently; UI just won't show those.
      }
    }
    _cache['__infra_nodes_by_id__'] = result;
    return result;
  }

  // For tests / hot-restart edge cases.
  void clearCache() => _cache.clear();
}
