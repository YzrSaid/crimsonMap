enum MapNodeType { infrastructure, barrier, intermediate, indoorInfra, unknown }

MapNodeType _parseType(String? raw) {
  switch (raw) {
    case 'infrastructure':
      return MapNodeType.infrastructure;
    case 'barrier':
      return MapNodeType.barrier;
    case 'intermediate':
      return MapNodeType.intermediate;
    case 'indoorinfra':
      return MapNodeType.indoorInfra;
    default:
      return MapNodeType.unknown;
  }
}

class MapNode {
  final String nodeId;
  final String name;
  final MapNodeType type;
  final double? latitude;
  final double? longitude;
  final String? relatedInfraId;
  final String? relatedRoomId;
  final String campusId;
  final bool isActive;

  const MapNode({
    required this.nodeId,
    required this.name,
    required this.type,
    required this.latitude,
    required this.longitude,
    required this.relatedInfraId,
    required this.relatedRoomId,
    required this.campusId,
    required this.isActive,
  });

  bool get hasCoordinates => latitude != null && longitude != null;

  factory MapNode.fromJson(Map<String, dynamic> json) {
    return MapNode(
      nodeId: json['node_id'] as String? ?? '',
      name: (json['name'] as String? ?? '').trim(),
      type: _parseType(json['type'] as String?),
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      relatedInfraId: json['related_infra_id'] as String?,
      relatedRoomId: json['related_room_id'] as String?,
      campusId: json['campus_id'] as String? ?? '',
      isActive: json['is_active'] as bool? ?? true,
    );
  }
}
