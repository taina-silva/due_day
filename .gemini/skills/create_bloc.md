# Standard Procedure: Create BLoC (create_bloc.md)

This guide describes how to create BLoCs, Events, and States using `flutter_bloc` and `Equatable` in the **DueDay** application.

---

## 🛠️ BLoC Design Pattern

### Rule 1: Use Equatable
All Events and States must extend `Equatable` to ensure accurate equality comparisons. This prevents unnecessary UI rebuilds when identical states are emitted.

### Rule 2: Clean State Management
Group BLoC elements into separate files within `presentation/bloc/`:
- `my_feature_bloc.dart` — Handlers mapping events to state transitions.
- `my_feature_event.dart` — Actions dispatched by the UI.
- `my_feature_state.dart` — States rendered by the UI.

### Rule 3: Error States
Always include a generic `Error` state to propagate failure messages from UseCases to UI overlays.

---

## 📝 BLoC Component Templates

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
  final String message;
  const AccountError(this.message);

  @override
  List<Object?> get props => [message];
}
```

### 3. BLoC Class (`presentation/bloc/account_bloc.dart`)
```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:due_day/features/accounts/domain/usecases/get_accounts.dart';
import '../../skills/account_event.dart';
import '../../skills/account_state.dart';

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
      (failure) => emit(AccountError(failure.message)),
      (accounts) => emit(AccountLoaded(accounts)),
    );
  }
}
```
