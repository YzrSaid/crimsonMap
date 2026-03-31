import '../../domain/entities/building.dart';

class BuildingModel extends Building {
  const BuildingModel({
    required super.id,
    required super.name,
    super.description,
    required super.latitude,
    required super.longitude,
    super.imageUrl,
    super.floors,
  });

  factory BuildingModel.fromJson(Map<String, dynamic> json) => BuildingModel(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String?,
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        imageUrl: json['image_url'] as String?,
        floors: json['floors'] as int?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'latitude': latitude,
        'longitude': longitude,
        'image_url': imageUrl,
        'floors': floors,
      };
}
