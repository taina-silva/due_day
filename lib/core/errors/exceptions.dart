class ServerException implements Exception {
  final String message;
  final String? code;
  const ServerException([this.message = 'A server error occurred', this.code]);
}

class CacheException implements Exception {
  final String message;
  const CacheException([this.message = 'Cache error']);
}
