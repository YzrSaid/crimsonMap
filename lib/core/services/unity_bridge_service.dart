import 'package:flutter/services.dart';
import '../constants/app_constants.dart';

/// Handles communication between Flutter and the Unity AR module via
/// a [MethodChannel]. The Unity side exposes the same channel name.
class UnityBridgeService {
  UnityBridgeService._();

  static const MethodChannel _channel =
      MethodChannel(AppConstants.unityMethodChannel);

  /// Sends a navigation payload to Unity to start AR navigation.
  /// [payload] should be a JSON-encodable map built by [ARPayloadBuilder].
  static Future<void> startNavigation(Map<String, dynamic> payload) async {
    await _channel.invokeMethod('startNavigation', payload);
  }

  /// Stops any active AR navigation session in Unity.
  static Future<void> stopNavigation() async {
    await _channel.invokeMethod('stopNavigation');
  }

  /// Sends a destination update mid-navigation.
  static Future<void> updateDestination(String destinationId) async {
    await _channel.invokeMethod('updateDestination', {'destinationId': destinationId});
  }

  /// Registers a handler for messages coming back from Unity.
  static void onUnityMessage(void Function(String message) handler) {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onMessage') {
        handler(call.arguments as String);
      }
    });
  }
}
