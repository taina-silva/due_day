import 'package:due_day/core/design_system/components/buttons/app_text_button.dart';
import 'package:due_day/core/design_system/components/messenger/app_messenger.dart';
import 'package:due_day/core/design_system/theme/theme.dart';
import 'package:due_day/core/l10n/app_localizations.dart';
import 'package:due_day/core/l10n/l10n_extension.dart';
import 'package:due_day/core/utils/app_constants.dart';
import 'package:due_day/core/utils/extensions/num_extension.dart';
import 'package:due_day/features/accounts/domain/entities/account_entity.dart';
import 'package:due_day/features/accounts/presentation/bloc/account_bloc.dart';
import 'package:due_day/features/accounts/presentation/bloc/account_event.dart';
import 'package:due_day/features/accounts/presentation/bloc/account_state.dart';
import 'package:due_day/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:due_day/features/auth/presentation/bloc/auth_state.dart';
import 'package:due_day/features/categories/domain/entities/category_entity.dart';
import 'package:due_day/features/categories/presentation/bloc/category_bloc.dart';
import 'package:due_day/features/categories/presentation/bloc/category_event.dart';
import 'package:due_day/features/categories/presentation/bloc/category_state.dart';
import 'package:due_day/features/transactions/domain/entities/transaction_entity.dart';
import 'package:due_day/features/transactions/presentation/bloc/transaction_bloc.dart';
import 'package:due_day/features/transactions/presentation/bloc/transaction_event.dart';
import 'package:due_day/features/transactions/presentation/bloc/transaction_state.dart';
import 'package:due_day/features/transactions/presentation/utils/transaction_failure_extension.dart';
import 'package:due_day/features/transactions/presentation/widgets/bottom_sheets/account_selection_bottom_sheet.dart';
import 'package:due_day/features/transactions/presentation/widgets/bottom_sheets/category_selection_bottom_sheet.dart';
import 'package:due_day/features/transactions/presentation/widgets/form/transaction_amount_input.dart';
import 'package:due_day/features/transactions/presentation/widgets/form/transaction_form_fields.dart';
import 'package:due_day/features/transactions/presentation/widgets/form/transaction_type_selector.dart';
import 'package:due_day/features/transactions/presentation/widgets/navigation/transaction_navigation_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class TransactionCreateForm extends StatefulWidget {
  final TransactionEntity? transaction;
  final VoidCallback? onSave;

  const TransactionCreateForm({this.transaction, this.onSave, super.key});

  @override
  State<TransactionCreateForm> createState() => _TransactionCreateFormState();
}

class _TransactionCreateFormState extends State<TransactionCreateForm> {
  TransactionType _selectedType = TransactionType.expense;

  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  CategoryEntity? _selectedCategory;
  AccountEntity? _selectedAccountFrom;
  AccountEntity? _selectedAccountTo;
  bool _isRecurring = false;
  bool _isPaid = true;
  TransactionFrequency _selectedFrequency = TransactionFrequency.none;

  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();

    context.read<CategoryBloc>().add(LoadCategories());
    context.read<AccountBloc>().add(LoadAccounts());

    if (widget.transaction != null) {
      final t = widget.transaction!;
      _selectedType = t.type;
      _notesController.text = t.notes ?? '';
      _selectedDate = t.dueDate ?? t.createdAt;
      _isRecurring = t.isRecurring;
      _isPaid = t.paid;
      _selectedFrequency = t.frequency;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized && widget.transaction != null) {
      _isInitialized = true;
      final t = widget.transaction!;

      // Format amount
      final numberFormat = NumberFormat.currency(
        locale: context.localeString,
        symbol: '',
        decimalDigits: 2,
      );
      _amountController.text = numberFormat.format(t.amount).trim();

      // Look up entities
      _updateEntitiesFromState();
    }
  }

  void _updateEntitiesFromState() {
    if (widget.transaction == null) return;
    final t = widget.transaction!;

    final categoryState = context.read<CategoryBloc>().state;
    if (categoryState is CategoryLoaded && t.category != null) {
      try {
        _selectedCategory = categoryState.categories.firstWhere(
          (c) => c.id == t.category,
        );
      } catch (_) {}
    }

    final accountState = context.read<AccountBloc>().state;
    if (accountState is AccountLoaded) {
      if (t.accountFrom != null) {
        try {
          _selectedAccountFrom = accountState.accounts.firstWhere(
            (a) => a.id == t.accountFrom,
          );
        } catch (_) {}
      }
      if (t.accountTo != null) {
        try {
          _selectedAccountTo = accountState.accounts.firstWhere(
            (a) => a.id == t.accountTo,
          );
        } catch (_) {}
      }
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final l10n = AppLocalizations.of(context);

    return MultiBlocListener(
      listeners: [
        BlocListener<CategoryBloc, CategoryState>(
          listener: (context, state) {
            if (state is CategoryLoaded) {
              setState(() => _updateEntitiesFromState());
            }
          },
        ),
        BlocListener<AccountBloc, AccountState>(
          listener: (context, state) {
            if (state is AccountLoaded) {
              setState(() => _updateEntitiesFromState());
            }
          },
        ),
        BlocListener<TransactionBloc, TransactionState>(
          listener: (context, state) {
            if (state is TransactionError) {
              AppMessenger.showError(
                context,
                state.failure.toLocalizedString(context),
              );
            }
          },
        ),
      ],
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          spacing.largeExtraLarge.width,
          0,
          spacing.largeExtraLarge.width,
          AppConstants.bottomSafeArea(
            context,
            padding: spacing.largeExtraLarge.height,
          ),
        ),
        children: [
          SizedBox(height: spacing.twoExtraLarge.height),
          if (widget.transaction == null) ...[
            TransactionNavigationButtons(l10n: l10n),
            SizedBox(height: spacing.twoExtraLarge.height),
          ],
          TransactionTypeSelector(
            selectedType: _selectedType,
            onTypeChanged: _onTypeChanged,
          ),
          SizedBox(height: spacing.twoExtraLarge.height),
          TransactionAmountInput(
            selectedType: _selectedType,
            controller: _amountController,
            l10n: l10n,
          ),
          SizedBox(height: spacing.twoExtraLarge.height),
          TransactionFormFields(
            selectedType: _selectedType,
            selectedDate: _selectedDate,
            selectedCategory: _selectedCategory,
            selectedAccountFrom: _selectedAccountFrom,
            selectedAccountTo: _selectedAccountTo,
            isRecurring: _isRecurring,
            isPaid: _isPaid,
            selectedFrequency: _selectedFrequency,
            notesController: _notesController,
            l10n: l10n,
            onSelectDate: _handleSelectDate,
            onSelectCategory: _handleSelectCategory,
            onSelectAccountFrom: _handleSelectAccountFrom,
            onSelectAccountTo: _handleSelectAccountTo,
            onIsRecurringChanged: (val) => setState(() => _isRecurring = val),
            onIsPaidChanged: (val) => setState(() => _isPaid = val),
            onFrequencyChanged: (freq) =>
                setState(() => _selectedFrequency = freq),
          ),
          SizedBox(height: spacing.twoExtraLarge.height),
          AppTextButtonPrimary(
            label: l10n.transactionsSave,
            onPressed: _submit,
          ),
          SizedBox(
            height:
                AppConstants.bottomNavHeight +
                AppConstants.bottomSafeArea(
                  context,
                  padding: spacing.twoExtraLarge.height,
                ),
          ),
        ],
      ),
    );
  }

  // --- Methods and Handlers ---

  void _onTypeChanged(TransactionType type) {
    setState(() {
      _selectedType = type;
    });
  }

  Future<void> _handleSelectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  Future<void> _handleSelectCategory() async {
    final result = await showModalBottomSheet<CategoryEntity>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (context) => const CategorySelectionBottomSheet(),
    );
    if (result != null) {
      setState(() => _selectedCategory = result);
    }
  }

  Future<void> _handleSelectAccountFrom() async {
    final result = await showModalBottomSheet<AccountEntity>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (context) => const AccountSelectionBottomSheet(),
    );
    if (result != null) {
      setState(() => _selectedAccountFrom = result);
    }
  }

  Future<void> _handleSelectAccountTo() async {
    final result = await showModalBottomSheet<AccountEntity>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (context) => const AccountSelectionBottomSheet(),
    );
    if (result != null) {
      setState(() => _selectedAccountTo = result);
    }
  }

  void _submit() {
    final l10n = AppLocalizations.of(context);
    // Remove all non-numeric characters and parse as cents
    final digitsOnly = _amountController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final amountValue = double.tryParse(digitsOnly);

    if (amountValue == null || amountValue <= 0) return;

    final amount = amountValue / 100;

    final authState = context.read<AuthBloc>().state;
    String userId = 'guest';
    if (authState is AuthAuthenticated) {
      userId = authState.user.uid;
    }

    final transaction = TransactionEntity(
      id: widget.transaction?.id ?? const Uuid().v4(),
      userId: userId,
      category: _selectedCategory?.id,
      accountFrom: _selectedAccountFrom?.id,
      accountTo: _selectedAccountTo?.id,
      amount: amount, // Always positive now
      type: _selectedType,
      dueDate: _selectedDate,
      paid: _isPaid,
      notes: _notesController.text,
      isRecurring: _isRecurring,
      frequency: _selectedFrequency,
      createdAt: widget.transaction?.createdAt ?? DateTime.now(),
    );

    if (widget.transaction != null) {
      context.read<TransactionBloc>().add(UpdateTransactionEvent(transaction));
    } else {
      context.read<TransactionBloc>().add(AddTransactionEvent(transaction));

      _amountController.clear();
      _notesController.clear();
      setState(() {
        _selectedCategory = null;
        _selectedAccountFrom = null;
        _selectedAccountTo = null;
      });
    }

    AppMessenger.showSuccess(context, l10n.transactionsSavedSuccess);

    if (widget.onSave != null) {
      widget.onSave!();
    }
  }
}
