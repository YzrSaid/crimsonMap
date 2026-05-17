class MapEdge {
  final String edgeId;
  final String fromNodeId;
  final String toNodeId;
  final String pathType;
  final bool isActive;

  const MapEdge({
    required this.edgeId,
    required this.fromNodeId,
    required this.toNodeId,
    required this.pathType,
    required this.isActive,
  });

  factory MapEdge.fromJson(Map<String, dynamic> json) {
    return MapEdge(
      edgeId: json['edge_id'] as String? ?? '',
      fromNodeId: json['from_node'] as String? ?? '',
      toNodeId: json['to_node'] as String? ?? '',
      pathType: json['path_type'] as String? ?? '',
      isActive: (json['is_active'] as bool? ?? true) &&
          !(json['is_deleted'] as bool? ?? false),
    );
  }
}
