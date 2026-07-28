import 'dart:async';

import 'package:due_day/features/schedule/domain/usecases/get_schedule_data.dart';
import 'package:due_day/features/schedule/presentation/bloc/schedule_load_event.dart';
import 'package:due_day/features/schedule/presentation/bloc/schedule_load_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ScheduleLoadBloc extends Bloc<ScheduleLoadEvent, ScheduleLoadState> {
  final GetScheduleData getScheduleData;

  StreamSubscription? _scheduleSubscription;

  ScheduleLoadBloc({required this.getScheduleData}) : super(ScheduleInitial()) {
    on<LoadScheduleData>(_onLoadScheduleData);
    on<ScheduleDataUpdated>(_onScheduleDataUpdated);
    on<ScheduleLoadFailed>(_onScheduleLoadFailed);
  }

  void _onLoadScheduleData(
    LoadScheduleData event,
    Emitter<ScheduleLoadState> emit,
  ) {
    emit(ScheduleLoading());
    _scheduleSubscription?.cancel();
    _scheduleSubscription = getScheduleData.execute().listen((result) {
      result.fold(
        (failure) => add(ScheduleLoadFailed(failure)),
        (summary) => add(ScheduleDataUpdated(summary)),
      );
    });
  }

  void _onScheduleDataUpdated(
    ScheduleDataUpdated event,
    Emitter<ScheduleLoadState> emit,
  ) {
    emit(ScheduleLoaded(event.summary));
  }

  void _onScheduleLoadFailed(
    ScheduleLoadFailed event,
    Emitter<ScheduleLoadState> emit,
  ) {
    emit(ScheduleError(event.failure));
  }

  @override
  Future<void> close() {
    _scheduleSubscription?.cancel();
    return super.close();
  }
}
