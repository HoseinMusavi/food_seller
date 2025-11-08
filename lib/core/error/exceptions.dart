// lib/core/error/exceptions.dart
class ServerException implements Exception {
  final String message;
  const ServerException({this.message = 'An unexpected error occurred.'});
}

class CacheException implements Exception {}