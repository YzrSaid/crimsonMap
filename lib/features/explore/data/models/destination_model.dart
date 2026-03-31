import '../../domain/entities/destination.dart';

class DestinationModel extends Destination {
  const DestinationModel({
    required super.id,
    required super.name,
    super.description,
    required super.latitude,
    required super.longitude,
    super.imageUrl,
    required super.categoryId,
    required super.buildingId,
    super.floor,
    super.roomNumber,
  });

  factory DestinationModel.fromJson(Map<String, dynamic> json) =>
      DestinationModel(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String?,
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        imageUrl: json['image_url'] as String?,
        categoryId: json['category_id'] as String,
        buildingId: json['building_id'] as String,
        floor: json['floor'] as String?,
        roomNumber: json['room_number'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'latitude': latitude,
        'longitude': longitude,
        'image_url': imageUrl,
        'category_id': categoryId,
        'building_id': buildingId,
        'floor': floor,
        'room_number': roomNumber,
      };
}
