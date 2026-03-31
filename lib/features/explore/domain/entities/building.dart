class Building {
  final String id;
  final String name;
  final String? description;
  final double latitude;
  final double longitude;
  final String? imageUrl;
  final int? floors;

  const Building({
    required this.id,
    required this.name,
    this.description,
    required this.latitude,
    required this.longitude,
    this.imageUrl,
    this.floors,
  });
}
