class ArMarker {
  final String id;
  final String destinationId;
  final double latitude;
  final double longitude;
  final String? label;
  final double? altitude;

  const ArMarker({
    required this.id,
    required this.destinationId,
    required this.latitude,
    required this.longitude,
    this.label,
    this.altitude,
  });
}
