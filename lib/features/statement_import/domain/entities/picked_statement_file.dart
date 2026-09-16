import 'package:equatable/equatable.dart';

class PickedStatementFile extends Equatable {
  final String fileName;
  final String content;

  const PickedStatementFile({required this.fileName, required this.content});

  @override
  List<Object?> get props => [fileName, content];
}
