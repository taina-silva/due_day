---
name: create-bloc
description: Use when creating a new BLoC (events, states, bloc class) for a DueDay feature's presentation layer. Covers Equatable event/state patterns, the Load Bloc/Action Bloc split for streamed features, file layout under presentation/bloc/, and error-state handling.
---

# Standard Procedure: Create BLoC

This guide describes how to create BLoCs, Events, and States using `flutter_bloc` and `Equatable` in the **DueDay** application.

---

## 🛠️ BLoC Design Pattern

### Rule 1: Use Equatable
All Events and States must extend `Equatable` to ensure accurate equality comparisons. This prevents unnecessary UI rebuilds when identical states are emitted — but see Rule 4 for the failure mode this causes on action blocs.

### Rule 2: Decide single BLoC vs. Load Bloc / Action Bloc split
This is the first decision to make, before writing any file:

- **Split into `XLoadBloc` + `XActionBloc`** (the default) whenever the feature has a **real-time list stream** (e.g. `getX().listen(...)` off a Firestore snapshot) **and** mutating actions (add/update/delete). Reference implementation: `categories` (`CategoryLoadBloc` + `CategoryActionBloc`).
- **Keep a single `XBloc`** only when there is no persistent stream underneath — e.g. a one-shot settings toggle, a form that just submits once and reports a result, or a feature with no list at all.

Never emit an add/update/delete result onto the *same* bloc/state hierarchy that also carries a loaded list. See [architecture.md](../../docs/architecture.md#load-bloc--action-bloc-separation-standard-for-streamed-features) for the full rationale (short version: any other screen that reads that bloc just for the list will misinterpret a transient action state and blank out).

### Rule 3: Clean State Management
Group BLoC elements into separate files within `presentation/bloc/`. For a split feature:
- `x_load_bloc.dart` / `x_load_event.dart` / `x_load_state.dart`
- `x_action_bloc.dart` / `x_action_event.dart` / `x_action_state.dart`

For a single (unsplit) bloc:
- `my_feature_bloc.dart` — Handlers mapping events to state transitions.
- `my_feature_event.dart` — Actions dispatched by the UI.
- `my_feature_state.dart` — States rendered by the UI.

### Rule 4: Error State Naming & the Equatable Trap
- Error states are always named `XError` (holding a `Failure failure` field) — never `XFailure`. This matches every existing bloc in the app (`AccountError`, `TransactionError`, `CategoryError`, `ScheduleError`, `AuthError`, `DashboardError`, `NotificationsError`); do not introduce a one-off name.
- **Action blocs must emit an `XActionInProgress` state before the result**, even though nothing in the UI necessarily renders a spinner for it. Reason: if two consecutive submissions fail with the *exact same* `Failure` (same message/code), `Equatable` treats the second `XActionError` as identical to the first, `flutter_bloc` suppresses the "no-op" emission, and any `BlocListener` waiting to show `AppMessenger.showError` a second time never fires. Emitting `XActionInProgress` in between guarantees every result is a genuine state transition.

---

## 📝 Load Bloc / Action Bloc Templates (default pattern)

### 1. Load Events (`presentation/bloc/x_load_event.dart`)
```dart
import 'package:due_day/core/errors/failures.dart';
import 'package:due_day/features/x/domain/entities/x_entity.dart';
import 'package:equatable/equatable.dart';

abstract class XLoadEvent extends Equatable {
  const XLoadEvent();
  @override
  List<Object> get props => [];
}

class LoadX extends XLoadEvent {}

class XUpdated extends XLoadEvent {
  final List<XEntity> items;
  const XUpdated(this.items);
  @override
  List<Object> get props => [items];
}

class XLoadFailed extends XLoadEvent {
  final Failure failure;
  const XLoadFailed(this.failure);
  @override
  List<Object> get props => [failure];
}
```

### 2. Load States (`presentation/bloc/x_load_state.dart`)
```dart
import 'package:due_day/core/errors/failures.dart';
import 'package:due_day/features/x/domain/entities/x_entity.dart';
import 'package:equatable/equatable.dart';

abstract class XLoadState extends Equatable {
  const XLoadState();
  @override
  List<Object> get props => [];
}

class XInitial extends XLoadState {}
class XLoading extends XLoadState {}

class XLoaded extends XLoadState {
  final List<XEntity> items;
  const XLoaded({required this.items});
  @override
  List<Object> get props => [items];
}

class XError extends XLoadState {
  final Failure failure;
  const XError({required this.failure});
  @override
  List<Object> get props => [failure];
}
```

### 3. Load BLoC (`presentation/bloc/x_load_bloc.dart`)
```dart
import 'dart:async';

import 'package:due_day/features/x/domain/usecases/x_usecases.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'x_load_event.dart';
import 'x_load_state.dart';

class XLoadBloc extends Bloc<XLoadEvent, XLoadState> {
  final GetX getX;

  StreamSubscription? _subscription;

  XLoadBloc({required this.getX}) : super(XInitial()) {
    on<LoadX>(_onLoad);
    on<XUpdated>((event, emit) => emit(XLoaded(items: event.items)));
    on<XLoadFailed>((event, emit) => emit(XError(failure: event.failure)));
  }

  void _onLoad(LoadX event, Emitter<XLoadState> emit) {
    emit(XLoading());
    _subscription?.cancel();
    _subscription = getX().listen((result) {
      result.fold(
        (failure) => add(XLoadFailed(failure)),
        (items) => add(XUpdated(items)),
      );
    });
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
```

### 4. Action Events (`presentation/bloc/x_action_event.dart`)
```dart
import 'package:due_day/features/x/domain/entities/x_entity.dart';
import 'package:equatable/equatable.dart';

abstract class XActionEvent extends Equatable {
  const XActionEvent();
  @override
  List<Object> get props => [];
}

class AddXEvent extends XActionEvent {
  final XEntity item;
  const AddXEvent(this.item);
  @override
  List<Object> get props => [item];
}

class UpdateXEvent extends XActionEvent {
  final XEntity item;
  const UpdateXEvent(this.item);
  @override
  List<Object> get props => [item];
}

class DeleteXEvent extends XActionEvent {
  final String id;
  const DeleteXEvent(this.id);
  @override
  List<Object> get props => [id];
}
```

### 5. Action States (`presentation/bloc/x_action_state.dart`)
```dart
import 'package:due_day/core/errors/failures.dart';
import 'package:equatable/equatable.dart';

abstract class XActionState extends Equatable {
  const XActionState();
  @override
  List<Object> get props => [];
}

class XActionInitial extends XActionState {}
class XActionInProgress extends XActionState {}
class XActionSuccess extends XActionState {}

class XActionError extends XActionState {
  final Failure failure;
  const XActionError({required this.failure});
  @override
  List<Object> get props => [failure];
}
```

### 6. Action BLoC (`presentation/bloc/x_action_bloc.dart`)
```dart
import 'package:due_day/features/x/domain/usecases/x_usecases.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'x_action_event.dart';
import 'x_action_state.dart';

class XActionBloc extends Bloc<XActionEvent, XActionState> {
  final AddX addX;
  final UpdateX updateX;
  final DeleteX deleteX;

  XActionBloc({
    required this.addX,
    required this.updateX,
    required this.deleteX,
  }) : super(XActionInitial()) {
    on<AddXEvent>(_onAdd);
    on<UpdateXEvent>(_onUpdate);
    on<DeleteXEvent>(_onDelete);
  }

  Future<void> _onAdd(AddXEvent event, Emitter<XActionState> emit) async {
    emit(XActionInProgress());
    final result = await addX(event.item);
    result.fold(
      (failure) => emit(XActionError(failure: failure)),
      (_) => emit(XActionSuccess()),
    );
  }

  Future<void> _onUpdate(UpdateXEvent event, Emitter<XActionState> emit) async {
    emit(XActionInProgress());
    final result = await updateX(event.item);
    result.fold(
      (failure) => emit(XActionError(failure: failure)),
      (_) => emit(XActionSuccess()),
    );
  }

  Future<void> _onDelete(DeleteXEvent event, Emitter<XActionState> emit) async {
    emit(XActionInProgress());
    final result = await deleteX(event.id);
    result.fold(
      (failure) => emit(XActionError(failure: failure)),
      (_) => emit(XActionSuccess()),
    );
  }
}
```

Consuming pages read the list exclusively from `XLoadBloc` (`BlocBuilder<XLoadBloc, XLoadState>`, matching only `XInitial`/`XLoading`/`XLoaded`/`XError`) and never need to know `XActionBloc` exists unless they also submit mutations. The bottom sheet/form that submits mutations reads `XActionBloc` via a `BlocListener` — see [create-screen §Bottom Sheets with mutating actions](../create-screen/SKILL.md) for that half of the pattern.

Both blocs are registered as `sl.registerFactory` in the feature's injection module and both are provided in `main.dart`'s root `MultiBlocProvider` — see [dependency_injection.md](../../references/dependency_injection.md).

---

## 📝 Single BLoC Template (no persistent stream to leak into)

### 1. Events (`presentation/bloc/account_event.dart`)
```dart
import 'package:equatable/equatable.dart';

abstract class AccountEvent extends Equatable {
  const AccountEvent();

  @override
  List<Object?> get props => [];
}

class LoadAccountsEvent extends AccountEvent {
  final String userId;
  const LoadAccountsEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}
```

### 2. States (`presentation/bloc/account_state.dart`)
```dart
import 'package:equatable/equatable.dart';
import 'package:due_day/features/accounts/domain/entities/account_entity.dart';

abstract class AccountState extends Equatable {
  const AccountState();

  @override
  List<Object?> get props => [];
}

class AccountInitial extends AccountState {}
class AccountLoading extends AccountState {}

class AccountLoaded extends AccountState {
  final List<AccountEntity> accounts;
  const AccountLoaded(this.accounts);

  @override
  List<Object?> get props => [accounts];
}

class AccountError extends AccountState {
  final Failure failure;
  const AccountError(this.failure);

  @override
  List<Object?> get props => [failure];
}
```

### 3. BLoC Class (`presentation/bloc/account_bloc.dart`)
```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:due_day/features/accounts/domain/usecases/get_accounts.dart';
import 'account_event.dart';
import 'account_state.dart';

class AccountBloc extends Bloc<AccountEvent, AccountState> {
  final GetAccounts getAccounts;

  AccountBloc({required this.getAccounts}) : super(AccountInitial()) {
    on<LoadAccountsEvent>(_onLoadAccounts);
  }

  Future<void> _onLoadAccounts(
    LoadAccountsEvent event,
    Emitter<AccountState> emit,
  ) async {
    emit(AccountLoading());

    final result = await getAccounts(event.userId);

    result.fold(
      (failure) => emit(AccountError(failure)),
      (accounts) => emit(AccountLoaded(accounts)),
    );
  }
}
```

> Note: `accounts` predates the Load/Action split standard and still uses a single combined bloc despite having both a stream and mutations. Treat it as a migration candidate, not as a second valid pattern to copy for new features.
