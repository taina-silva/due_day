import 'package:due_day/core/design_system/components/structure/custom_app_bar.dart';
import 'package:due_day/core/design_system/components/structure/custom_scaffold.dart';
import 'package:due_day/core/design_system/theme/theme.dart';
import 'package:due_day/core/l10n/l10n_extension.dart';
import 'package:due_day/features/categories/domain/entities/category_entity.dart';
import 'package:due_day/features/categories/presentation/bloc/category_load_bloc.dart';
import 'package:due_day/features/categories/presentation/bloc/category_load_state.dart';
import 'package:due_day/features/transactions/domain/entities/transaction_entity.dart';
import 'package:due_day/features/transactions/presentation/bloc/transaction_bloc.dart';
import 'package:due_day/features/transactions/presentation/bloc/transaction_event.dart';
import 'package:due_day/features/transactions/presentation/bloc/transaction_state.dart';
import 'package:due_day/features/transactions/presentation/utils/transaction_failure_extension.dart';
import 'package:due_day/features/transactions/presentation/widgets/bottom_sheets/category_selection_bottom_sheet.dart';
import 'package:due_day/features/transactions/presentation/widgets/bottom_sheets/date_selection_bottom_sheet.dart';
import 'package:due_day/features/transactions/presentation/widgets/bottom_sheets/frequency_selection_bottom_sheet.dart';
import 'package:due_day/features/transactions/presentation/widgets/bottom_sheets/transaction_details_bottom_sheet.dart';
import 'package:due_day/features/transactions/presentation/widgets/bottom_sheets/transaction_filter_bottom_sheet.dart';
import 'package:due_day/features/transactions/presentation/widgets/filter/transaction_filter_bar.dart';
import 'package:due_day/features/transactions/presentation/widgets/list/transaction_history_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TransactionHistoryPage extends StatefulWidget {
  const TransactionHistoryPage({super.key});

  @override
  State<TransactionHistoryPage> createState() => _TransactionHistoryPageState();
}

class _TransactionHistoryPageState extends State<TransactionHistoryPage> {
  TransactionType? _selectedType;
  TransactionFrequency? _selectedFrequency;
  String? _selectedCategoryId;

  DateTime? _startDate;
  DateTime? _endDate;

  @override
  Widget build(BuildContext context) {
    final typography = context.typography;
    final l10n = context.l10n;

    final hasFilters =
        _selectedType != null ||
        _selectedCategoryId != null ||
        _selectedFrequency != null ||
        _startDate != null;

    return CustomScaffold(
      appBar: CustomAppBar(
        titleText: l10n.transactionsHistory,
        actions: [
          if (hasFilters)
            IconButton(
              icon: const Icon(Icons.filter_alt_off_outlined),
              tooltip: l10n.clear,
              onPressed: () {
                setState(() {
                  _selectedType = null;
                  _selectedCategoryId = null;
                  _selectedFrequency = null;
                  _startDate = null;
                  _endDate = null;
                });
                _loadTransactions();
              },
            ),
        ],
      ),
      body: SafeArea(
        child: BlocBuilder<CategoryLoadBloc, CategoryLoadState>(
          builder: (context, categoryState) {
            final categories = categoryState is CategoryLoaded
                ? categoryState.categories
                : <CategoryEntity>[];

            return Column(
              children: [
                TransactionFilterBar(
                  selectedType: _selectedType,
                  selectedCategoryId: _selectedCategoryId,
                  selectedFrequency: _selectedFrequency,
                  startDate: _startDate,
                  endDate: _endDate,
                  categories: categories,
                  onTypeChanged: (type) {
                    setState(() => _selectedType = type);
                    _loadTransactions();
                  },
                  onCategoryTap: _openCategorySelection,
                  onFrequencyTap: _openFrequencySelection,
                  onDateTap: () => _openDateSelection(categories),
                  onOpenAdvancedFilters: () => _openAdvancedFilters(categories),
                ),
                Expanded(
                  child: BlocBuilder<TransactionBloc, TransactionState>(
                    builder: (context, state) {
                      if (state is TransactionLoading) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (state is TransactionError) {
                        return Center(
                          child: Text(
                            state.failure.toLocalizedString(context),
                            style: typography.body.medium,
                          ),
                        );
                      } else if (state is TransactionLoaded) {
                        final transactions = state.transactions;
                        if (transactions.isEmpty) {
                          return Center(
                            child: Text(
                              l10n.transactionsEmpty,
                              style: typography.body.medium,
                            ),
                          );
                        }

                        return TransactionHistoryList(
                          transactions: transactions,
                          categories: categories,
                          onTransactionTap: _openTransactionDetails,
                        );
                      }

                      return Center(
                        child: Text(
                          l10n.transactionsEmpty,
                          style: typography.body.medium,
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _openCategorySelection() async {
    final result = await showModalBottomSheet<dynamic>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CategorySelectionBottomSheet(
        selectedCategoryId: _selectedCategoryId,
        showAllOption: true,
      ),
    );
    if (mounted) {
      if (result == null) {
        setState(() => _selectedCategoryId = null);
        _loadTransactions();
      } else if (result is CategoryEntity) {
        setState(() => _selectedCategoryId = result.id);
        _loadTransactions();
      }
    }
  }

  void _openFrequencySelection() async {
    final result = await showModalBottomSheet<TransactionFrequency?>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          FrequencySelectionBottomSheet(selectedFrequency: _selectedFrequency),
    );
    if (mounted) {
      setState(() => _selectedFrequency = result);
      _loadTransactions();
    }
  }

  void _openDateSelection(List<CategoryEntity> categories) async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DateSelectionBottomSheet(
        initialStartDate: _startDate,
        initialEndDate: _endDate,
      ),
    );

    if (mounted && result != null) {
      setState(() {
        _startDate = result['startDate'];
        _endDate = result['endDate'];
      });
      _loadTransactions();
    }
  }

  void _loadTransactions() {
    context.read<TransactionBloc>().add(
      LoadTransactions(
        type: _selectedType,
        frequency: _selectedFrequency,
        categoryId: _selectedCategoryId,
        startDate: _startDate,
        endDate: _endDate,
      ),
    );
  }

  void _openAdvancedFilters(List<CategoryEntity> categories) async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TransactionFilterBottomSheet(
        categories: categories,
        initialType: _selectedType,
        initialCategoryId: _selectedCategoryId,
        initialFrequency: _selectedFrequency,
        initialStartDate: _startDate,
        initialEndDate: _endDate,
      ),
    );

    if (mounted && result != null) {
      setState(() {
        _selectedType = result['type'];
        _selectedCategoryId = result['categoryId'];
        _selectedFrequency = result['frequency'];
        _startDate = result['startDate'];
        _endDate = result['endDate'];
      });
      _loadTransactions();
    }
  }

  void _openTransactionDetails(TransactionEntity transaction) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (context) =>
          TransactionDetailsBottomSheet(transaction: transaction),
    );
  }
}
