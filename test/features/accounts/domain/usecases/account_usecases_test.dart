import 'package:due_day/features/accounts/domain/usecases/account_usecases.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/account_test_helpers.dart';

void main() {
  late MockAccountRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(tAccountEntity);
  });

  setUp(() {
    mockRepository = MockAccountRepository();
  });

  group('Account UseCases Tests', () {
    test('AddAccount should call repository.addAccount', () async {
      // Arrange
      final usecase = AddAccount(mockRepository);
      when(
        () => mockRepository.addAccount(any()),
      ).thenAnswer((_) async => Right(tAccountEntity));

      // Act
      final result = await usecase(tAccountEntity);

      // Assert
      expect(result, Right(tAccountEntity));
      verify(() => mockRepository.addAccount(tAccountEntity)).called(1);
    });

    test('UpdateAccount should call repository.updateAccount', () async {
      // Arrange
      final usecase = UpdateAccount(mockRepository);
      when(
        () => mockRepository.updateAccount(any()),
      ).thenAnswer((_) async => Right(tAccountEntity));

      // Act
      final result = await usecase(tAccountEntity);

      // Assert
      expect(result, Right(tAccountEntity));
      verify(() => mockRepository.updateAccount(tAccountEntity)).called(1);
    });

    test('DeleteAccount should call repository.deleteAccount', () async {
      // Arrange
      final usecase = DeleteAccount(mockRepository);
      when(
        () => mockRepository.deleteAccount(any()),
      ).thenAnswer((_) async => const Right(null));

      // Act
      final result = await usecase('account-1');

      // Assert
      expect(result, const Right(null));
      verify(() => mockRepository.deleteAccount('account-1')).called(1);
    });

    test('GetAccounts should call repository.getAccounts', () async {
      // Arrange
      final usecase = GetAccounts(mockRepository);
      when(
        () => mockRepository.getAccounts(),
      ).thenAnswer((_) => Stream.value(Right([tAccountEntity])));

      // Act
      final stream = usecase();

      // Assert
      final result = await stream.first;
      expect(result.isRight(), true);
      result.fold((l) => fail('Should not be left'), (r) {
        expect(r, equals([tAccountEntity]));
      });
      verify(() => mockRepository.getAccounts()).called(1);
    });
  });
}
