import 'package:due_day/features/auth/domain/usecases/auth_usecases.dart';
import 'package:due_day/features/statement_import/domain/entities/import_review_item.dart';
import 'package:due_day/features/statement_import/domain/entities/parsed_statement_transaction.dart';
import 'package:due_day/features/statement_import/domain/errors/statement_import_failures.dart';
import 'package:due_day/features/statement_import/domain/usecases/build_review_list.dart';
import 'package:due_day/features/statement_import/domain/usecases/confirm_import.dart';
import 'package:due_day/features/statement_import/domain/usecases/parse_statement.dart';
import 'package:due_day/features/statement_import/domain/usecases/pick_statement_file.dart';
import 'package:due_day/features/statement_import/presentation/bloc/statement_import_event.dart';
import 'package:due_day/features/statement_import/presentation/bloc/statement_import_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// A single linear-wizard bloc (pick -> parse -> review -> confirm), unlike
/// the Action/Load split used elsewhere in this app. That split exists where
/// a long-lived Firestore stream needs to be managed alongside independent
/// actions; this flow has no live stream and no out-of-order actions, so one
/// bloc modeling a sequential state machine is simpler.
class StatementImportBloc
    extends Bloc<StatementImportEvent, StatementImportState> {
  final PickStatementFile pickStatementFile;
  final ParseStatement parseStatement;
  final BuildReviewList buildReviewList;
  final ConfirmImport confirmImport;
  final GetCurrentUser getCurrentUser;

  List<ParsedStatementTransaction>? _lastParsed;

  StatementImportBloc({
    required this.pickStatementFile,
    required this.parseStatement,
    required this.buildReviewList,
    required this.confirmImport,
    required this.getCurrentUser,
  }) : super(const StatementImportInitial()) {
    on<PickFileRequested>(_onPickFile);
    on<AccountSelected>(_onAccountSelected);
    on<ItemCategoryAssigned>(_onCategoryAssigned);
    on<ItemSelectionToggled>(_onSelectionToggled);
    on<ConfirmImportRequested>(_onConfirm);
    on<ImportFlowReset>((event, emit) => emit(const StatementImportInitial()));
  }

  Future<void> _onPickFile(
    PickFileRequested event,
    Emitter<StatementImportState> emit,
  ) async {
    emit(const StatementImportPicking());

    final pickedResult = await pickStatementFile();

    await pickedResult.fold(
      (failure) async => emit(StatementImportError(failure)),
      (picked) async {
        if (picked == null) {
          emit(const StatementImportInitial());
          return;
        }

        emit(const StatementImportParsing());

        final parseResult = parseStatement(
          fileName: picked.fileName,
          content: picked.content,
        );

        parseResult.fold((failure) => emit(StatementImportError(failure)), (
          parsed,
        ) {
          _lastParsed = parsed;
          emit(StatementImportAwaitingAccount(parsed));
        });
      },
    );
  }

  Future<void> _onAccountSelected(
    AccountSelected event,
    Emitter<StatementImportState> emit,
  ) async {
    final parsed = _lastParsed;
    if (parsed == null) return;

    emit(const StatementImportParsing());

    final result = await buildReviewList(parsed);

    result.fold(
      (failure) => emit(StatementImportError(failure)),
      (items) =>
          emit(StatementImportReviewing(account: event.account, items: items)),
    );
  }

  void _onCategoryAssigned(
    ItemCategoryAssigned event,
    Emitter<StatementImportState> emit,
  ) {
    final current = state;
    if (current is! StatementImportReviewing) return;
    if (event.itemIndex < 0 || event.itemIndex >= current.items.length) {
      return;
    }

    final currentItem = current.items[event.itemIndex];
    final updated = [...current.items];
    updated[event.itemIndex] = ImportReviewItem(
      parsed: currentItem.parsed,
      status: currentItem.status,
      selectedForImport: currentItem.selectedForImport,
      categoryId: event.category?.id,
      categoryName: event.category?.name,
    );

    emit(StatementImportReviewing(account: current.account, items: updated));
  }

  void _onSelectionToggled(
    ItemSelectionToggled event,
    Emitter<StatementImportState> emit,
  ) {
    final current = state;
    if (current is! StatementImportReviewing) return;
    if (event.itemIndex < 0 || event.itemIndex >= current.items.length) {
      return;
    }

    final updated = [...current.items];
    final item = updated[event.itemIndex];
    updated[event.itemIndex] = item.copyWith(
      selectedForImport: !item.selectedForImport,
    );

    emit(StatementImportReviewing(account: current.account, items: updated));
  }

  Future<void> _onConfirm(
    ConfirmImportRequested event,
    Emitter<StatementImportState> emit,
  ) async {
    final current = state;
    if (current is! StatementImportReviewing) return;

    emit(
      StatementImportConfirming(account: current.account, items: current.items),
    );

    final userResult = await getCurrentUser();

    await userResult.fold(
      (failure) async => emit(StatementImportError(failure)),
      (user) async {
        if (user == null) {
          emit(const StatementImportError(ImportPersistFailure()));
          return;
        }

        final result = await confirmImport(
          reviewItems: current.items,
          userId: user.uid,
          destinationAccountId: current.account.id,
        );

        result.fold(
          (failure) => emit(StatementImportError(failure)),
          (summary) => emit(StatementImportSuccess(summary)),
        );
      },
    );
  }
}
