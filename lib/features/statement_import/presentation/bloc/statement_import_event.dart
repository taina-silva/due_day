import 'package:due_day/features/accounts/domain/entities/account_entity.dart';
import 'package:due_day/features/categories/domain/entities/category_entity.dart';
import 'package:equatable/equatable.dart';

abstract class StatementImportEvent extends Equatable {
  const StatementImportEvent();

  @override
  List<Object?> get props => [];
}

class PickFileRequested extends StatementImportEvent {
  const PickFileRequested();
}

class AccountSelected extends StatementImportEvent {
  final AccountEntity account;

  const AccountSelected(this.account);

  @override
  List<Object?> get props => [account];
}

class ItemCategoryAssigned extends StatementImportEvent {
  final int itemIndex;
  final CategoryEntity? category;

  const ItemCategoryAssigned(this.itemIndex, this.category);

  @override
  List<Object?> get props => [itemIndex, category];
}

class ItemSelectionToggled extends StatementImportEvent {
  final int itemIndex;

  const ItemSelectionToggled(this.itemIndex);

  @override
  List<Object?> get props => [itemIndex];
}

class ConfirmImportRequested extends StatementImportEvent {
  const ConfirmImportRequested();
}

class ImportFlowReset extends StatementImportEvent {
  const ImportFlowReset();
}
