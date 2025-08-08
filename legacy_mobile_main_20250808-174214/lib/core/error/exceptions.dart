// Used for catching errors at the boundary (API/Storage)
class ServerException implements Exception {
  final String message;
  final int? statusCode;
  final String errorCode;

  ServerException({
    required this.message,
    this.statusCode,
    required this.errorCode,
  });
}

class CacheException implements Exception {}