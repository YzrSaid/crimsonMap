import 'dart:convert';
import 'package:flutter_unity_widget/flutter_unity_widget.dart';

// Bridge between Flutter and the Unity AR module. Sends messages to a
// GameObject in Unity named "FlutterMessageReceiver" (see
// unity/crimson_map/Assets/Scripts/ARSCene/FlutterMessageReceiver.cs).
//
// Lifecycle:
//   1. The AR screen builds a UnityWidget and, in onUnityCreated, calls
//      UnityBridgeService.attachController(controller).
//   2. On dispose / stopNavigation, the screen calls detachController().
class UnityBridgeService {
  UnityBridgeService._();

  static const String _gameObject = 'FlutterMessageReceiver';
  static UnityWidgetController? _controller;
  static void Function(Map<String, dynamic> message)? _onUnityMessage;

  static void attachController(UnityWidgetController controller) {
    _controller = controller;
  }

  static void detachController() {
    _controller = null;
  }

  // Called by the UnityWidget(onUnityMessage:) callback. Forwards parsed
  // JSON envelopes from FlutterMessageReceiver.SendToFlutter(...) to the
  // currently registered handler.
  static void dispatchIncoming(dynamic raw) {
    if (_onUnityMessage == null) return;
    final str = raw is String ? raw : raw.toString();
    try {
      final decoded = jsonDecode(str);
      if (decoded is Map<String, dynamic>) _onUnityMessage!(decoded);
    } catch (_) {
      _onUnityMessage!({'event': 'raw', 'data': str});
    }
  }

  static void onUnityMessage(void Function(Map<String, dynamic> message) handler) {
    _onUnityMessage = handler;
  }

  static Future<void> startNavigation(Map<String, dynamic> payload) async {
    await _post('StartNavigation', jsonEncode(payload));
  }

  static Future<void> stopNavigation() async {
    await _post('StopNavigation', '');
  }

  static Future<void> updateDestination(String destinationId) async {
    await _post('UpdateDestination', jsonEncode({'destinationId': destinationId}));
  }

  static Future<void> _post(String method, String message) async {
    final c = _controller;
    if (c == null) {
      throw StateError(
        'UnityBridgeService: no UnityWidgetController attached. '
        'Make sure UnityWidget(onUnityCreated:) calls attachController().',
      );
    }
    await c.postMessage(_gameObject, method, message);
  }
}
