import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Ocorreu um erro no servidor']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Erro de cache']);
}

class GenericFailure extends Failure {
  const GenericFailure([super.message = 'Ocorreu um erro inesperado']);
}
