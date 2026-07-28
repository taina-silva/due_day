import 'package:bloc_test/bloc_test.dart';
import 'package:due_day/core/errors/failures.dart';
import 'package:due_day/features/schedule/presentation/bloc/schedule_load_bloc.dart';
import 'package:due_day/features/schedule/presentation/bloc/schedule_load_event.dart';
import 'package:due_day/features/schedule/presentation/bloc/schedule_load_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/schedule_test_helpers.dart';

void main() {
  late MockGetScheduleData mockGetScheduleData;
  late ScheduleLoadBloc scheduleLoadBloc;

  setUp(() {
    mockGetScheduleData = MockGetScheduleData();
    scheduleLoadBloc = ScheduleLoadBloc(getScheduleData: mockGetScheduleData);
  });

  tearDown(() {
    scheduleLoadBloc.close();
  });

  test('initial state should be ScheduleInitial', () {
    expect(scheduleLoadBloc.state, equals(ScheduleInitial()));
  });

  group('LoadScheduleData Event', () {
    blocTest<ScheduleLoadBloc, ScheduleLoadState>(
      'should emit [ScheduleLoading, ScheduleLoaded] when data is loaded successfully',
      build: () {
        when(
          () => mockGetScheduleData.execute(),
        ).thenAnswer((_) => Stream.value(Right(tScheduleSummary)));
        return scheduleLoadBloc;
      },
      act: (bloc) => bloc.add(LoadScheduleData()),
      expect: () => [ScheduleLoading(), ScheduleLoaded(tScheduleSummary)],
      verify: (_) {
        verify(() => mockGetScheduleData.execute()).called(1);
      },
    );

    blocTest<ScheduleLoadBloc, ScheduleLoadState>(
      'should emit [ScheduleLoading, ScheduleError] when the stream fails',
      build: () {
        when(() => mockGetScheduleData.execute()).thenAnswer(
          (_) => Stream.value(const Left(ServerFailure('Schedule error'))),
        );
        return scheduleLoadBloc;
      },
      act: (bloc) => bloc.add(LoadScheduleData()),
      expect: () => [
        ScheduleLoading(),
        const ScheduleError(ServerFailure('Schedule error')),
      ],
    );
  });
}
