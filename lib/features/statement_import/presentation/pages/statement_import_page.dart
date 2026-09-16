import 'package:due_day/core/design_system/components/buttons/app_text_button.dart';
import 'package:due_day/core/design_system/components/messenger/app_messenger.dart';
import 'package:due_day/core/design_system/components/structure/custom_app_bar.dart';
import 'package:due_day/core/design_system/components/structure/custom_scaffold.dart';
import 'package:due_day/core/design_system/theme/theme.dart';
import 'package:due_day/core/injection/injection_container.dart' as di;
import 'package:due_day/core/l10n/l10n_extension.dart';
import 'package:due_day/core/utils/extensions/num_extension.dart';
import 'package:due_day/features/accounts/domain/entities/account_entity.dart';
import 'package:due_day/features/accounts/presentation/bloc/account_load_bloc.dart';
import 'package:due_day/features/accounts/presentation/bloc/account_load_event.dart';
import 'package:due_day/features/categories/domain/entities/category_entity.dart';
import 'package:due_day/features/categories/presentation/bloc/category_load_bloc.dart';
import 'package:due_day/features/categories/presentation/bloc/category_load_event.dart';
import 'package:due_day/features/statement_import/domain/entities/import_review_item.dart';
import 'package:due_day/features/statement_import/presentation/bloc/statement_import_bloc.dart';
import 'package:due_day/features/statement_import/presentation/bloc/statement_import_event.dart';
import 'package:due_day/features/statement_import/presentation/bloc/statement_import_state.dart';
import 'package:due_day/features/statement_import/presentation/utils/statement_import_failure_extension.dart';
import 'package:due_day/features/statement_import/presentation/widgets/import_review_list.dart';
import 'package:due_day/features/transactions/presentation/widgets/bottom_sheets/account_selection_bottom_sheet.dart';
import 'package:due_day/features/transactions/presentation/widgets/bottom_sheets/category_selection_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StatementImportPage extends StatefulWidget {
  const StatementImportPage({super.key});

  @override
  State<StatementImportPage> createState() => _StatementImportPageState();
}

class _StatementImportPageState extends State<StatementImportPage> {
  late final StatementImportBloc _bloc;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _bloc = di.sl<StatementImportBloc>();
    context.read<AccountLoadBloc>().add(LoadAccounts());
    context.read<CategoryLoadBloc>().add(LoadCategories());
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocProvider.value(
      value: _bloc,
      child: BlocConsumer<StatementImportBloc, StatementImportState>(
        listener: (context, state) {
          if (state is StatementImportAwaitingAccount) {
            _openAccountPicker(context);
          } else if (state is StatementImportSuccess) {
            _isSubmitting = false;
            AppMessenger.showSuccess(
              context,
              l10n.statementImportSuccessMessage(
                state.summary.importedCount,
                state.summary.skippedDuplicateCount,
                state.summary.skippedByUserCount,
              ),
            );
            Navigator.of(context).pop();
          } else if (state is StatementImportError) {
            _isSubmitting = false;
            AppMessenger.showError(
              context,
              state.failure.toLocalizedString(context),
            );
          }
        },
        builder: (context, state) {
          return CustomScaffold(
            appBar: CustomAppBar(titleText: l10n.statementImportTitle),
            body: SafeArea(child: _buildBody(context, state)),
            bottomNavigationBar: state is StatementImportReviewing
                ? _buildConfirmBar(context, state)
                : null,
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, StatementImportState state) {
    switch (state) {
      case StatementImportParsing():
      case StatementImportConfirming():
      case StatementImportSuccess():
        return const Center(child: CircularProgressIndicator());
      case StatementImportAwaitingAccount():
        // The account-picker bottom sheet is about to open on top of this
        // body (see the BlocConsumer listener) — an empty body avoids a
        // second spinner competing with the sheet's own loading state
        // under the modal scrim.
        return const SizedBox.shrink();
      case StatementImportReviewing():
        return ImportReviewList(
          items: state.items,
          onToggleSelected: (index) =>
              _bloc.add(ItemSelectionToggled(index)),
          onTapCategory: (index) => _openCategoryPicker(context, index, state),
        );
      case StatementImportInitial():
      case StatementImportPicking():
      case StatementImportError():
        return _buildIntro(context, state is StatementImportPicking);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildIntro(BuildContext context, bool isPicking) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;
    final l10n = context.l10n;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(spacing.largeExtraLarge.width),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.upload_file_rounded,
              size: 56.scale,
              color: colors.resource.primary,
            ),
            SizedBox(height: spacing.medium.height),
            Text(
              l10n.statementImportIntroTitle,
              style: typography.title.medium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: spacing.small.height),
            Text(
              l10n.statementImportIntroBody,
              style: typography.body.medium.copyWith(
                color: colors.resource.secondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: spacing.large.height),
            AppTextButtonPrimary(
              label: l10n.statementImportSelectFile,
              isLoading: isPicking,
              onPressed: () => _bloc.add(const PickFileRequested()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmBar(
    BuildContext context,
    StatementImportReviewing state,
  ) {
    final spacing = context.spacing;
    final l10n = context.l10n;

    final selectedCount = state.items
        .where(
          (item) =>
              item.selectedForImport &&
              item.status != ImportReviewStatus.alreadyImported,
        )
        .length;

    return SafeArea(
      top: false,
      minimum: EdgeInsets.only(bottom: spacing.small.height),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: spacing.medium.width,
          vertical: spacing.small.height,
        ),
        child: AppTextButtonPrimary(
          label: l10n.statementImportConfirmButton(selectedCount),
          isLoading: _isSubmitting,
          isEnabled: selectedCount > 0,
          onPressed: () {
            setState(() => _isSubmitting = true);
            _bloc.add(const ConfirmImportRequested());
          },
        ),
      ),
    );
  }

  Future<void> _openAccountPicker(BuildContext context) async {
    // No `backgroundColor: Colors.transparent` here: unlike
    // CategorySelectionBottomSheet, AccountSelectionBottomSheet paints no
    // background of its own — a transparent modal background left the
    // dimmed barrier showing straight through the sheet's content.
    final account = await showModalBottomSheet<AccountEntity>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (_) => const AccountSelectionBottomSheet(),
    );

    if (!mounted) return;

    if (account != null) {
      _bloc.add(AccountSelected(account));
    } else {
      _bloc.add(const ImportFlowReset());
    }
  }

  Future<void> _openCategoryPicker(
    BuildContext context,
    int index,
    StatementImportReviewing state,
  ) async {
    final currentCategoryId = state.items[index].categoryId;

    final result = await showModalBottomSheet<CategoryEntity?>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          CategorySelectionBottomSheet(selectedCategoryId: currentCategoryId),
    );

    if (!mounted) return;

    if (result is CategoryEntity) {
      _bloc.add(ItemCategoryAssigned(index, result));
    }
  }
}
