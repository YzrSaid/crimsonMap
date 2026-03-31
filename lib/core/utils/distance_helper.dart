import 'dart:math';

class DistanceHelper {
  DistanceHelper._();

  static const double _earthRadiusKm = 6371.0;

  /// Returns distance in meters between two lat/lng points using the Haversine formula.
  static double haversine(double lat1, double lon1, double lat2, double lon2) {
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) * cos(_toRadians(lat2)) * sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return _earthRadiusKm * c * 1000;
  }

  /// Formats a distance in meters into a human-readable string.
  static String format(double meters) {
    if (meters < 1000) {
      return '${meters.toStringAsFixed(0)} m';
    }
    return '${(meters / 1000).toStringAsFixed(1)} km';
  }

  static double _toRadians(double degrees) => degrees * pi / 180;
}
