import 'package:bloc_test/bloc_test.dart';
import 'package:due_day/core/errors/failures.dart';
import 'package:due_day/features/accounts/presentation/bloc/account_load_bloc.dart';
import 'package:due_day/features/accounts/presentation/bloc/account_load_event.dart';
import 'package:due_day/features/accounts/presentation/bloc/account_load_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/account_test_helpers.dart';

void main() {
  late MockGetAccounts mockGetAccounts;
  late AccountLoadBloc accountLoadBloc;

  setUp(() {
    mockGetAccounts = MockGetAccounts();

    accountLoadBloc = AccountLoadBloc(getAccounts: mockGetAccounts);
  });

  tearDown(() {
    accountLoadBloc.close();
  });

  test('initial state should be AccountInitial', () {
    expect(accountLoadBloc.state, equals(AccountInitial()));
  });

  group('LoadAccounts Event', () {
    blocTest<AccountLoadBloc, AccountLoadState>(
      'should emit [AccountLoading, AccountLoaded] on success',
      build: () {
        when(
          () => mockGetAccounts(),
        ).thenAnswer((_) => Stream.value(Right([tAccountEntity])));
        return accountLoadBloc;
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

    blocTest<AccountLoadBloc, AccountLoadState>(
      'should emit [AccountLoading, AccountError] on stream failure',
      build: () {
        when(() => mockGetAccounts()).thenAnswer(
          (_) => Stream.value(const Left(ServerFailure('Fetch failed'))),
        );
        return accountLoadBloc;
      },
      act: (bloc) => bloc.add(LoadAccounts()),
      expect: () => [
        AccountLoading(),
        const AccountError(failure: ServerFailure('Fetch failed')),
      ],
    );
  });
}
