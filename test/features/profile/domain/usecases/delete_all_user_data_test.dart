import 'package:due_day/core/errors/exceptions.dart';
import 'package:due_day/core/observability/observability_service.dart';
import 'package:due_day/features/profile/data/datasources/user_data_remote_data_source.dart';
import 'package:due_day/features/profile/data/repositories/user_data_repository_impl.dart';
import 'package:due_day/features/profile/domain/errors/user_data_failures.dart';
import 'package:due_day/features/profile/domain/usecases/delete_all_user_data.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class MockUserDataRemoteDataSource extends Mock
    implements UserDataRemoteDataSource {}

void main() {
  late MockUserDataRemoteDataSource dataSource;
  late DeleteAllUserData deleteAllUserData;

  setUp(() {
    dataSource = MockUserDataRemoteDataSource();
    deleteAllUserData = DeleteAllUserData(
      UserDataRepositoryImpl(
        remoteDataSource: dataSource,
        observability: ObservabilityServiceImpl(sinks: const []),
      ),
    );
  });

  test('SET-001: returns Right when every collection is deleted', () async {
    when(() => dataSource.deleteAll()).thenAnswer((_) async {});

    expect(await deleteAllUserData(), const Right(null));
    verify(() => dataSource.deleteAll()).called(1);
  });

  test('SET-001: failure maps to DeleteUserDataFailure', () async {
    when(
      () => dataSource.deleteAll(),
    ).thenThrow(const ServerException('boom', 'unavailable'));

    final result = await deleteAllUserData();

    expect(result.getLeft().toNullable(), isA<DeleteUserDataFailure>());
  });
}
