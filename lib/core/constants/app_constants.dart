class AppConstants {
  AppConstants._();

  static const String appName = 'Crimson Map';
  static const String appVersion = '2.0.0';
  static const String university = 'Western Mindanao State University';
  static const String universityShort = 'WMSU';

  // Mapbox
  static const String mapboxAccessToken = String.fromEnvironment('MAPBOX_ACCESS_TOKEN');

  // Map defaults (WMSU campus center)
  static const double defaultLatitude = 6.9214;
  static const double defaultLongitude = 122.0790;
  static const double defaultZoom = 17.0;

  // QR Scanner
  static const int qrScanDelayMs = 1500;
}
