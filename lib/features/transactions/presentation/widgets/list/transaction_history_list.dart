import 'package:collection/collection.dart';
import 'package:due_day/core/design_system/theme/theme.dart';
import 'package:due_day/core/l10n/l10n_extension.dart';
import 'package:due_day/core/utils/app_constants.dart';
import 'package:due_day/core/utils/extensions/num_extension.dart';
import 'package:due_day/features/categories/domain/entities/category_entity.dart';
import 'package:due_day/features/transactions/domain/entities/transaction_entity.dart';
import 'package:due_day/features/transactions/presentation/widgets/list/transaction_item.dart';
import 'package:flutter/material.dart';

/// Broad, relative buckets the history list groups transactions into,
/// declared in the order they are rendered.
enum _HistorySection { upcoming, today, lastWeek, lastMonth, past }

/// A single row rendered by the list: either a section header or a
/// transaction belonging to the section right above it.
class _HistoryRow {
  final _HistorySection? header;
  final TransactionEntity? transaction;

  const _HistoryRow.header(_HistorySection section)
    : header = section,
      transaction = null;

  const _HistoryRow.transaction(TransactionEntity tx)
    : header = null,
      transaction = tx;
}

class TransactionHistoryList extends StatefulWidget {
  final List<TransactionEntity> transactions;
  final List<CategoryEntity> categories;
  final Function(TransactionEntity)? onTransactionTap;

  const TransactionHistoryList({
    required this.transactions,
    required this.categories,
    this.onTransactionTap,
    super.key,
  });

  @override
  State<TransactionHistoryList> createState() => _TransactionHistoryListState();
}

class _TransactionHistoryListState extends State<TransactionHistoryList> {
  static const int _pageSize = 20;
  static const double _loadMoreThreshold = 200;

  final ScrollController _scrollController = ScrollController();
  late int _visibleCount;

  @override
  void initState() {
    super.initState();
    _visibleCount = _pageSize < widget.transactions.length
        ? _pageSize
        : widget.transactions.length;
    _scrollController.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(covariant TransactionHistoryList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_visibleCount > widget.transactions.length) {
      _visibleCount = widget.transactions.length;
    }
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final threshold =
        _scrollController.position.maxScrollExtent - _loadMoreThreshold;
    if (_scrollController.position.pixels >= threshold) {
      _loadMore();
    }
  }

  void _loadMore() {
    if (_visibleCount >= widget.transactions.length) return;
    final next = _visibleCount + _pageSize;
    setState(() {
      _visibleCount = next < widget.transactions.length
          ? next
          : widget.transactions.length;
    });
  }

  /// The date a transaction is grouped and sorted under: its due date when
  /// scheduled, otherwise the date it was recorded. A transaction created
  /// today for a bill due next week must not surface under "Today".
  DateTime _effectiveDate(TransactionEntity tx) => tx.dueDate ?? tx.createdAt;

  DateTime _dayOnly(DateTime date) => DateTime(date.year, date.month, date.day);

  _HistorySection _sectionFor(
    TransactionEntity tx,
    DateTime today,
    DateTime weekAgo,
    DateTime monthAgo,
  ) {
    final date = _dayOnly(_effectiveDate(tx));
    if (date.isAfter(today)) return _HistorySection.upcoming;
    if (date == today) return _HistorySection.today;
    if (!date.isBefore(weekAgo)) return _HistorySection.lastWeek;
    if (!date.isBefore(monthAgo)) return _HistorySection.lastMonth;
    return _HistorySection.past;
  }

  /// Buckets every transaction into its relative section, sorts each bucket
  /// (soonest first for upcoming items, most recent first otherwise), and
  /// concatenates them in display order, each paired with its section.
  List<MapEntry<_HistorySection, TransactionEntity>> _orderTransactions() {
    final today = _dayOnly(DateTime.now());
    final weekAgo = today.subtract(const Duration(days: 7));
    final monthAgo = today.subtract(const Duration(days: 30));

    final buckets = <_HistorySection, List<TransactionEntity>>{
      for (final section in _HistorySection.values) section: [],
    };
    for (final tx in widget.transactions) {
      buckets[_sectionFor(tx, today, weekAgo, monthAgo)]!.add(tx);
    }

    buckets[_HistorySection.upcoming]!.sort(
      (a, b) => _effectiveDate(a).compareTo(_effectiveDate(b)),
    );
    for (final section in _HistorySection.values) {
      if (section == _HistorySection.upcoming) continue;
      buckets[section]!.sort(
        (a, b) => _effectiveDate(b).compareTo(_effectiveDate(a)),
      );
    }

    return [
      for (final section in _HistorySection.values)
        for (final tx in buckets[section]!) MapEntry(section, tx),
    ];
  }

  String _sectionLabel(BuildContext context, _HistorySection section) {
    final l10n = context.l10n;
    switch (section) {
      case _HistorySection.upcoming:
        return l10n.transactionsSectionUpcoming.toUpperCase();
      case _HistorySection.today:
        return l10n.dateToday.toUpperCase();
      case _HistorySection.lastWeek:
        return l10n.transactionsSectionLastWeek.toUpperCase();
      case _HistorySection.lastMonth:
        return l10n.transactionsSectionLastMonth.toUpperCase();
      case _HistorySection.past:
        return l10n.transactionsSectionPast.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    final typography = context.typography;
    final spacing = context.spacing;

    final orderedEntries = _orderTransactions();
    final visibleEntries = orderedEntries.take(_visibleCount).toList();
    final hasMore = _visibleCount < orderedEntries.length;

    final rows = <_HistoryRow>[];
    _HistorySection? lastSection;
    for (final entry in visibleEntries) {
      if (entry.key != lastSection) {
        rows.add(_HistoryRow.header(entry.key));
        lastSection = entry.key;
      }
      rows.add(_HistoryRow.transaction(entry.value));
    }

    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.fromLTRB(
        spacing.largeExtraLarge.width,
        0,
        spacing.largeExtraLarge.width,
        AppConstants.bottomNavHeight +
            AppConstants.bottomSafeArea(context, padding: spacing.large.height),
      ),
      itemCount: rows.length + (hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= rows.length) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: spacing.medium.height),
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        final row = rows[index];

        if (row.header != null) {
          return Padding(
            padding: EdgeInsets.only(
              top: index == 0 ? 0 : spacing.medium.height,
              bottom: spacing.small.height,
            ),
            child: Text(
              _sectionLabel(context, row.header!),
              style: typography.label.small.copyWith(
                fontWeight: FontWeight.bold,
                color: context.colors.resource.secondary,
              ),
            ),
          );
        }

        final tx = row.transaction!;
        final category = widget.categories.firstWhereOrNull(
          (c) => c.id == tx.category,
        );

        return Padding(
          padding: EdgeInsets.only(bottom: spacing.medium.height),
          child: TransactionItem(
            transaction: tx,
            category: category,
            onTap: widget.onTransactionTap != null
                ? () => widget.onTransactionTap!(tx)
                : null,
          ),
        );
      },
    );
  }
}
