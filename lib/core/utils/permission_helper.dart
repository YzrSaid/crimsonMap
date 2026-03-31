import 'package:permission_handler/permission_handler.dart';

class PermissionHelper {
  PermissionHelper._();

  static Future<bool> requestCamera() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  static Future<bool> requestLocation() async {
    final status = await Permission.locationWhenInUse.request();
    return status.isGranted;
  }

  static Future<bool> isCameraGranted() async => Permission.camera.isGranted;

  static Future<bool> isLocationGranted() async =>
      Permission.locationWhenInUse.isGranted;

  static Future<void> openAppSettings() => openAppSettings();
}
