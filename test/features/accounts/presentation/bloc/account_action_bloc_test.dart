import 'package:bloc_test/bloc_test.dart';
import 'package:due_day/core/errors/failures.dart';
import 'package:due_day/features/accounts/presentation/bloc/account_action_bloc.dart';
import 'package:due_day/features/accounts/presentation/bloc/account_action_event.dart';
import 'package:due_day/features/accounts/presentation/bloc/account_action_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/account_test_helpers.dart';

void main() {
  late MockAddAccount mockAddAccount;
  late MockUpdateAccount mockUpdateAccount;
  late MockDeleteAccount mockDeleteAccount;
  late AccountActionBloc accountActionBloc;

  setUpAll(() {
    registerFallbackValue(tAccountEntity);
  });

  setUp(() {
    mockAddAccount = MockAddAccount();
    mockUpdateAccount = MockUpdateAccount();
    mockDeleteAccount = MockDeleteAccount();

    accountActionBloc = AccountActionBloc(
      addAccount: mockAddAccount,
      updateAccount: mockUpdateAccount,
      deleteAccount: mockDeleteAccount,
    );
  });

  tearDown(() {
    accountActionBloc.close();
  });

  test('initial state should be AccountActionInitial', () {
    expect(accountActionBloc.state, equals(AccountActionInitial()));
  });

  group('AddAccountEvent', () {
    blocTest<AccountActionBloc, AccountActionState>(
      'should emit [AccountActionInProgress, AccountActionSuccess] when '
      'AddAccount succeeds',
      build: () {
        when(
          () => mockAddAccount(any()),
        ).thenAnswer((_) async => Right(tAccountEntity));
        return accountActionBloc;
      },
      act: (bloc) => bloc.add(AddAccountEvent(tAccountEntity)),
      expect: () => [AccountActionInProgress(), AccountActionSuccess()],
      verify: (_) {
        verify(() => mockAddAccount(tAccountEntity)).called(1);
      },
    );

    blocTest<AccountActionBloc, AccountActionState>(
      'should emit [AccountActionInProgress, AccountActionError] when '
      'AddAccount fails',
      build: () {
        when(
          () => mockAddAccount(any()),
        ).thenAnswer((_) async => const Left(ServerFailure('Add failed')));
        return accountActionBloc;
      },
      act: (bloc) => bloc.add(AddAccountEvent(tAccountEntity)),
      expect: () => [
        AccountActionInProgress(),
        const AccountActionError(failure: ServerFailure('Add failed')),
      ],
    );

    blocTest<AccountActionBloc, AccountActionState>(
      'should surface two consecutive identical failures as separate states',
      build: () {
        when(
          () => mockAddAccount(any()),
        ).thenAnswer((_) async => const Left(ServerFailure('Add failed')));
        return accountActionBloc;
      },
      act: (bloc) {
        bloc.add(AddAccountEvent(tAccountEntity));
        bloc.add(AddAccountEvent(tAccountEntity));
      },
      expect: () => [
        AccountActionInProgress(),
        const AccountActionError(failure: ServerFailure('Add failed')),
        AccountActionInProgress(),
        const AccountActionError(failure: ServerFailure('Add failed')),
      ],
    );
  });

  group('UpdateAccountEvent', () {
    blocTest<AccountActionBloc, AccountActionState>(
      'should emit [AccountActionInProgress, AccountActionSuccess] when '
      'UpdateAccount succeeds',
      build: () {
        when(
          () => mockUpdateAccount(any()),
        ).thenAnswer((_) async => Right(tAccountEntity));
        return accountActionBloc;
      },
      act: (bloc) => bloc.add(UpdateAccountEvent(tAccountEntity)),
      expect: () => [AccountActionInProgress(), AccountActionSuccess()],
      verify: (_) {
        verify(() => mockUpdateAccount(tAccountEntity)).called(1);
      },
    );

    blocTest<AccountActionBloc, AccountActionState>(
      'should emit [AccountActionInProgress, AccountActionError] when '
      'UpdateAccount fails',
      build: () {
        when(
          () => mockUpdateAccount(any()),
        ).thenAnswer((_) async => const Left(ServerFailure('Update failed')));
        return accountActionBloc;
      },
      act: (bloc) => bloc.add(UpdateAccountEvent(tAccountEntity)),
      expect: () => [
        AccountActionInProgress(),
        const AccountActionError(failure: ServerFailure('Update failed')),
      ],
    );
  });

  group('DeleteAccountEvent', () {
    blocTest<AccountActionBloc, AccountActionState>(
      'should emit [AccountActionInProgress, AccountActionSuccess] when '
      'DeleteAccount succeeds',
      build: () {
        when(
          () => mockDeleteAccount(any()),
        ).thenAnswer((_) async => const Right(null));
        return accountActionBloc;
      },
      act: (bloc) => bloc.add(const DeleteAccountEvent('account-1')),
      expect: () => [AccountActionInProgress(), AccountActionSuccess()],
      verify: (_) {
        verify(() => mockDeleteAccount('account-1')).called(1);
      },
    );

    blocTest<AccountActionBloc, AccountActionState>(
      'should emit [AccountActionInProgress, AccountActionError] when '
      'DeleteAccount fails',
      build: () {
        when(
          () => mockDeleteAccount(any()),
        ).thenAnswer((_) async => const Left(ServerFailure('Delete failed')));
        return accountActionBloc;
      },
      act: (bloc) => bloc.add(const DeleteAccountEvent('account-1')),
      expect: () => [
        AccountActionInProgress(),
        const AccountActionError(failure: ServerFailure('Delete failed')),
      ],
    );
  });
}
