---
name: create-bloc
description: Use when creating a new BLoC (events, states, bloc class) for a DueDay feature's presentation layer. Covers Equatable event/state patterns, the Load Bloc/Action Bloc split for streamed features, file layout under presentation/bloc/, and error-state handling.
---

# Create BLoC

## Rules

1. Events and states extend `Equatable`.
2. **Decide first:** live list stream + add/update/delete → split into `XLoadBloc` + `XActionBloc` (default, reference: `categories`). No stream → single `XBloc`. Why: [architecture.md](../../docs/architecture.md#load--action-bloc-split).
3. Files in `presentation/bloc/`: `x_load_{bloc,event,state}.dart` + `x_action_{bloc,event,state}.dart` (or `x_{bloc,event,state}.dart`).
4. Error state is always `XError` / `XActionError` with a `Failure failure` field.
5. Action handlers **emit `XActionInProgress` before the result**. Otherwise two identical consecutive errors are equal under `Equatable`, the second emission is dropped, and the error toast doesn't show again.
6. Register both blocs with `registerFactory` and provide them in `main.dart` ([dependency_injection.md](../../docs/dependency_injection.md)).

## Load BLoC

```dart
// x_load_event.dart
abstract class XLoadEvent extends Equatable { const XLoadEvent(); @override List<Object> get props => []; }
class LoadX extends XLoadEvent {}
class XUpdated extends XLoadEvent { final List<XEntity> items; const XUpdated(this.items); @override List<Object> get props => [items]; }
class XLoadFailed extends XLoadEvent { final Failure failure; const XLoadFailed(this.failure); @override List<Object> get props => [failure]; }

// x_load_state.dart
abstract class XLoadState extends Equatable { const XLoadState(); @override List<Object> get props => []; }
class XInitial extends XLoadState {}
class XLoading extends XLoadState {}
class XLoaded extends XLoadState { final List<XEntity> items; const XLoaded({required this.items}); @override List<Object> get props => [items]; }
class XError extends XLoadState { final Failure failure; const XError({required this.failure}); @override List<Object> get props => [failure]; }

// x_load_bloc.dart
class XLoadBloc extends Bloc<XLoadEvent, XLoadState> {
  final GetX getX;
  StreamSubscription? _subscription;

  XLoadBloc({required this.getX}) : super(XInitial()) {
    on<LoadX>((event, emit) {
      emit(XLoading());
      _subscription?.cancel();
      _subscription = getX().listen((r) => r.fold((f) => add(XLoadFailed(f)), (items) => add(XUpdated(items))));
    });
    on<XUpdated>((e, emit) => emit(XLoaded(items: e.items)));
    on<XLoadFailed>((e, emit) => emit(XError(failure: e.failure)));
  }

  @override
  Future<void> close() { _subscription?.cancel(); return super.close(); }
}
```

## Action BLoC

```dart
// x_action_event.dart: AddXEvent(XEntity item), UpdateXEvent(XEntity item), DeleteXEvent(String id)

// x_action_state.dart
class XActionInitial extends XActionState {}
class XActionInProgress extends XActionState {}
class XActionSuccess extends XActionState {}
class XActionError extends XActionState { final Failure failure; const XActionError({required this.failure}); @override List<Object> get props => [failure]; }

// x_action_bloc.dart
class XActionBloc extends Bloc<XActionEvent, XActionState> {
  final AddX addX; final UpdateX updateX; final DeleteX deleteX;

  XActionBloc({required this.addX, required this.updateX, required this.deleteX}) : super(XActionInitial()) {
    on<AddXEvent>((e, emit) => _run(emit, () => addX(e.item)));
    on<UpdateXEvent>((e, emit) => _run(emit, () => updateX(e.item)));
    on<DeleteXEvent>((e, emit) => _run(emit, () => deleteX(e.id)));
  }

  Future<void> _run(Emitter<XActionState> emit, Future<Either<Failure, void>> Function() action) async {
    emit(XActionInProgress());
    final result = await action();
    result.fold((f) => emit(XActionError(failure: f)), (_) => emit(XActionSuccess()));
  }
}
```

- Pages read the list only from `XLoadBloc`.
- Forms and bottom sheets that mutate listen to `XActionBloc` ([create-screen](../create-screen/SKILL.md#bottom-sheets-with-mutating-actions)).
- A single bloc follows the same shape: `Initial` / `Loading` / `Loaded` / `Error`, with `result.fold(...)`.
