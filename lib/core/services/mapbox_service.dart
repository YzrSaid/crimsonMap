import '../constants/app_constants.dart';

/// Wrapper around Mapbox configuration and utility methods.
/// Actual map rendering is handled by [mapbox_maps_flutter] widgets.
class MapboxService {
  MapboxService._();

  static String get accessToken => AppConstants.mapboxAccessToken;

  static String styleUri({bool isDark = false}) =>
      isDark ? 'mapbox://styles/mapbox/dark-v11' : 'mapbox://styles/mapbox/streets-v12';

  /// Builds a static map image URL for a given coordinate.
  static String staticMapUrl({
    required double latitude,
    required double longitude,
    int width = 600,
    int height = 400,
    int zoom = 16,
  }) {
    return 'https://api.mapbox.com/styles/v1/mapbox/streets-v12/static/'
        '$longitude,$latitude,$zoom,0/${width}x$height'
        '?access_token=${AppConstants.mapboxAccessToken}';
  }
}
