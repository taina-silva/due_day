class ServerException implements Exception {
  final String message;
  const ServerException([this.message = 'Ocorreu um erro no servidor']);
}

class CacheException implements Exception {
  final String message;
  const CacheException([this.message = 'Erro de cache']);
}
