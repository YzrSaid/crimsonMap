import '../../domain/entities/ar_marker.dart';

class ArMarkerModel extends ArMarker {
  const ArMarkerModel({
    required super.id,
    required super.destinationId,
    required super.latitude,
    required super.longitude,
    super.label,
    super.altitude,
  });

  factory ArMarkerModel.fromJson(Map<String, dynamic> json) => ArMarkerModel(
        id: json['id'] as String,
        destinationId: json['destination_id'] as String,
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        label: json['label'] as String?,
        altitude: (json['altitude'] as num?)?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'destination_id': destinationId,
        'latitude': latitude,
        'longitude': longitude,
        'label': label,
        'altitude': altitude,
      };
}
