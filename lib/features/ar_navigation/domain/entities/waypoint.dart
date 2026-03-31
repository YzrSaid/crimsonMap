class Waypoint {
  final int order;
  final double latitude;
  final double longitude;
  final String? instruction;

  const Waypoint({
    required this.order,
    required this.latitude,
    required this.longitude,
    this.instruction,
  });
}
