class ServerException implements Exception {
  final String message;
  const ServerException([this.message = 'A server error occurred.']);

  @override
  String toString() => 'ServerException: $message';
}

class NetworkException implements Exception {
  final String message;
  const NetworkException([this.message = 'No internet connection.']);

  @override
  String toString() => 'NetworkException: $message';
}

class AuthException implements Exception {
  final String message;
  const AuthException([this.message = 'Authentication failed.']);

  @override
  String toString() => 'AuthException: $message';
}

class NotFoundException implements Exception {
  final String message;
  const NotFoundException([this.message = 'Resource not found.']);

  @override
  String toString() => 'NotFoundException: $message';
}

class CacheException implements Exception {
  final String message;
  const CacheException([this.message = 'Cache error occurred.']);

  @override
  String toString() => 'CacheException: $message';
}

class PermissionException implements Exception {
  final String message;
  const PermissionException([this.message = 'Permission denied.']);

  @override
  String toString() => 'PermissionException: $message';
}

class UnityBridgeException implements Exception {
  final String message;
  const UnityBridgeException([this.message = 'Unity bridge error.']);

  @override
  String toString() => 'UnityBridgeException: $message';
}
