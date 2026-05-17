import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

enum UserLocationFailure {
  serviceDisabled,
  permissionDenied,
  permissionDeniedForever,
  unknown,
}

class UserLocationException implements Exception {
  final UserLocationFailure reason;
  UserLocationException(this.reason);

  @override
  String toString() => 'UserLocationException($reason)';
}

Future<void> _ensureLocationPermission() async {
  final serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    throw UserLocationException(UserLocationFailure.serviceDisabled);
  }

  var permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }
  if (permission == LocationPermission.denied) {
    throw UserLocationException(UserLocationFailure.permissionDenied);
  }
  if (permission == LocationPermission.deniedForever) {
    throw UserLocationException(UserLocationFailure.permissionDeniedForever);
  }
}

/// Resolves the user's current position, requesting permission if needed.
/// Throws [UserLocationException] when location is unavailable.
Future<Position> resolveCurrentUserPosition() async {
  await _ensureLocationPermission();
  return Geolocator.getCurrentPosition(
    locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.high,
      timeLimit: Duration(seconds: 10),
    ),
  );
}

/// Continuous stream of position updates. Emits nothing until permission is
/// granted; errors out via [UserLocationException] otherwise.
final userPositionStreamProvider = StreamProvider<Position>((ref) async* {
  await _ensureLocationPermission();
  yield* Geolocator.getPositionStream(
    locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 2,
    ),
  );
});
