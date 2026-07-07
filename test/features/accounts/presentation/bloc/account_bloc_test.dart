import 'package:bloc_test/bloc_test.dart';
import 'package:due_day/core/errors/failures.dart';
import 'package:due_day/features/accounts/presentation/bloc/account_bloc.dart';
import 'package:due_day/features/accounts/presentation/bloc/account_event.dart';
import 'package:due_day/features/accounts/presentation/bloc/account_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/account_test_helpers.dart';

void main() {
  late MockAddAccount mockAddAccount;
  late MockUpdateAccount mockUpdateAccount;
  late MockDeleteAccount mockDeleteAccount;
  late MockGetAccounts mockGetAccounts;
  late AccountBloc accountBloc;

  setUpAll(() {
    registerFallbackValue(tAccountEntity);
  });

  setUp(() {
    mockAddAccount = MockAddAccount();
    mockUpdateAccount = MockUpdateAccount();
    mockDeleteAccount = MockDeleteAccount();
    mockGetAccounts = MockGetAccounts();

    accountBloc = AccountBloc(
      addAccount: mockAddAccount,
      updateAccount: mockUpdateAccount,
      deleteAccount: mockDeleteAccount,
      getAccounts: mockGetAccounts,
    );
  });

  tearDown(() {
    accountBloc.close();
  });

  test('initial state should be AccountInitial', () {
    expect(accountBloc.state, equals(AccountInitial()));
  });

  group('LoadAccounts Event', () {
    blocTest<AccountBloc, AccountState>(
      'should emit [AccountLoading, AccountLoaded] on success',
      build: () {
        when(
          () => mockGetAccounts(),
        ).thenAnswer((_) => Stream.value(Right([tAccountEntity])));
        return accountBloc;
      },
      act: (bloc) => bloc.add(LoadAccounts()),
      expect: () => [
        AccountLoading(),
        AccountLoaded(accounts: [tAccountEntity]),
      ],
      verify: (_) {
        verify(() => mockGetAccounts()).called(1);
      },
    );

    blocTest<AccountBloc, AccountState>(
      'should emit [AccountLoading, AccountError] on stream failure',
      build: () {
        when(() => mockGetAccounts()).thenAnswer(
          (_) => Stream.value(const Left(ServerFailure('Fetch failed'))),
        );
        return accountBloc;
      },
      act: (bloc) => bloc.add(LoadAccounts()),
      expect: () => [
        AccountLoading(),
        const AccountError(failure: ServerFailure('Fetch failed')),
      ],
    );
  });

  group('AddAccountEvent', () {
    blocTest<AccountBloc, AccountState>(
      'should call AddAccount usecase and do nothing on success (UI listens to stream)',
      build: () {
        when(
          () => mockAddAccount(any()),
        ).thenAnswer((_) async => Right(tAccountEntity));
        return accountBloc;
      },
      act: (bloc) => bloc.add(AddAccountEvent(tAccountEntity)),
      expect: () => <AccountState>[],
      verify: (_) {
        verify(() => mockAddAccount(tAccountEntity)).called(1);
      },
    );

    blocTest<AccountBloc, AccountState>(
      'should emit AccountError when AddAccount fails',
      build: () {
        when(
          () => mockAddAccount(any()),
        ).thenAnswer((_) async => const Left(ServerFailure('Add failed')));
        return accountBloc;
      },
      act: (bloc) => bloc.add(AddAccountEvent(tAccountEntity)),
      expect: () => [const AccountError(failure: ServerFailure('Add failed'))],
    );
  });

  group('UpdateAccountEvent', () {
    blocTest<AccountBloc, AccountState>(
      'should call UpdateAccount usecase and do nothing on success',
      build: () {
        when(
          () => mockUpdateAccount(any()),
        ).thenAnswer((_) async => Right(tAccountEntity));
        return accountBloc;
      },
      act: (bloc) => bloc.add(UpdateAccountEvent(tAccountEntity)),
      expect: () => <AccountState>[],
      verify: (_) {
        verify(() => mockUpdateAccount(tAccountEntity)).called(1);
      },
    );
  });

  group('DeleteAccountEvent', () {
    blocTest<AccountBloc, AccountState>(
      'should call DeleteAccount usecase and do nothing on success',
      build: () {
        when(
          () => mockDeleteAccount(any()),
        ).thenAnswer((_) async => const Right(null));
        return accountBloc;
      },
      act: (bloc) => bloc.add(const DeleteAccountEvent('account-1')),
      expect: () => <AccountState>[],
      verify: (_) {
        verify(() => mockDeleteAccount('account-1')).called(1);
      },
    );
  });
}
