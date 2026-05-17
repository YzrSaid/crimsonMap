class MapInfo {
  final String mapId;
  final String name;
  final double centerLat;
  final double centerLng;
  final List<String> campusIds;

  const MapInfo({
    required this.mapId,
    required this.name,
    required this.centerLat,
    required this.centerLng,
    required this.campusIds,
  });

  factory MapInfo.fromJson(Map<String, dynamic> json) {
    final campuses = (json['campus_included'] as List?)?.cast<String>() ?? const [];
    return MapInfo(
      mapId: json['map_id'] as String? ?? '',
      name: json['map_name'] as String? ?? 'Untitled Map',
      centerLat: (json['center_lat'] as num?)?.toDouble() ?? 0,
      centerLng: (json['center_lng'] as num?)?.toDouble() ?? 0,
      campusIds: campuses,
    );
  }
}
