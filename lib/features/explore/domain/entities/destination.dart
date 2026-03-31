class Destination {
  final String id;
  final String name;
  final String? description;
  final double latitude;
  final double longitude;
  final String? imageUrl;
  final String categoryId;
  final String buildingId;
  final String? floor;
  final String? roomNumber;

  const Destination({
    required this.id,
    required this.name,
    this.description,
    required this.latitude,
    required this.longitude,
    this.imageUrl,
    required this.categoryId,
    required this.buildingId,
    this.floor,
    this.roomNumber,
  });
}
