import 'package:due_day/core/design_system/components/buttons/app_text_button.dart';
import 'package:due_day/core/design_system/components/form_fields/app_dropdown_field.dart';
import 'package:due_day/core/design_system/components/form_fields/app_text_field.dart';
import 'package:due_day/core/design_system/theme/theme.dart';
import 'package:due_day/core/l10n/app_localizations.dart';
import 'package:due_day/core/l10n/l10n_extension.dart';
import 'package:due_day/core/utils/extensions/num_extension.dart';
import 'package:due_day/core/utils/formatters/currency_input_formatter.dart';
import 'package:due_day/core/utils/validators/validators.dart';
import 'package:due_day/features/accounts/domain/entities/account_category.dart';
import 'package:due_day/features/accounts/domain/entities/account_entity.dart';
import 'package:due_day/features/accounts/presentation/bloc/account_bloc.dart';
import 'package:due_day/features/accounts/presentation/bloc/account_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class AddEditAccountBottomSheet extends StatefulWidget {
  final AccountEntity? account;
  final Function(
    String name,
    AccountCategory category,
    double balance,
    int? dueDay,
  )
  onSave;

  const AddEditAccountBottomSheet({
    required this.onSave,
    super.key,
    this.account,
  });

  @override
  State<AddEditAccountBottomSheet> createState() =>
      _AddEditAccountBottomSheetState();
}

class _AddEditAccountBottomSheetState extends State<AddEditAccountBottomSheet> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _balanceController;
  late TextEditingController _dueDayController;

  AccountCategory? _selectedCategory;

  bool _isInit = false;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.account?.name ?? '');
    _balanceController = TextEditingController();
    _dueDayController = TextEditingController(
      text: widget.account?.dueDay?.toString() ?? '',
    );
    _selectedCategory = widget.account?.category;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      _isInit = true;
      if (widget.account != null) {
        final numberFormat = NumberFormat.currency(
          locale: context.localeString,
          symbol: '',
          decimalDigits: 2,
        );
        _balanceController.text = numberFormat
            .format(widget.account!.balance)
            .trim();
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    _dueDayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final typography = context.typography;
    final dimensions = context.dimensions;
    final l10n = AppLocalizations.of(context);

    final isEditing = widget.account != null;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: dimensions.spacing.medium.width,
        right: dimensions.spacing.medium.width,
        top: dimensions.spacing.large.height,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurfaceVariant.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(dimensions.radius.circle),
                ),
              ),
            ),
            SizedBox(height: dimensions.spacing.large.height),
            Text(
              isEditing ? l10n.accountsEditAccount : l10n.accountsAddAccount,
              style: typography.title.large.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: dimensions.spacing.extraLarge.height),
            AppTextField(
              controller: _nameController,
              label: l10n.accountsNameLabel,
              hintText: l10n.accountsNameHint,
              prefixIcon: Icons.account_balance_wallet_outlined,
              validator: Validators.requiredField(l10n),
            ),
            SizedBox(height: dimensions.spacing.large.height),
            AppDropdownField<AccountCategory>(
              value: _selectedCategory,
              label: l10n.accountsCategoryLabel,
              hintText: l10n.hintSelect,
              prefixIcon: Icons.category_outlined,
              items: AccountCategory.values
                  .map(
                    (category) => DropdownMenuItem(
                      value: category,
                      child: Text(category.localizedName(l10n)),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                });
              },
              validator: Validators.requiredSelection<AccountCategory>(l10n),
            ),
            SizedBox(height: dimensions.spacing.large.height),
            AppTextField(
              controller: _balanceController,
              label: l10n.accountsBalanceLabel,
              hintText: '0,00',
              prefixIcon: Icons.attach_money_rounded,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                CurrencyInputFormatter(locale: context.localeString),
              ],
              validator: Validators.requiredField(l10n),
            ),
            if (_selectedCategory == AccountCategory.creditCard) ...[
              SizedBox(height: dimensions.spacing.large.height),
              AppTextField(
                controller: _dueDayController,
                label: l10n.accountsDueDateLabel,
                hintText: '1-31',
                prefixIcon: Icons.calendar_today_outlined,
                keyboardType: TextInputType.number,
                maxLength: 2,
                validator: (value) {
                  if (value == null || value.isEmpty) return null;
                  final day = int.tryParse(value);
                  if (day == null || day < 1 || day > 31) {
                    return l10n.validatorRequired;
                  }
                  return null;
                },
              ),
            ],
            SizedBox(height: dimensions.spacing.extraLarge.height),
            Row(
              children: [
                Expanded(
                  child: AppTextButtonSecondary(
                    label: l10n.profileCancel,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                SizedBox(width: dimensions.spacing.medium.width),
                Expanded(
                  child: AppTextButtonPrimary(
                    label: l10n.accountsSaveAccount,
                    onPressed: _submit,
                  ),
                ),
              ],
            ),
            if (isEditing) ...[
              SizedBox(height: dimensions.spacing.medium.height),
              AppTextButtonSecondary(
                label: l10n.accountsDeleteAccount,
                onPressed: () => _onDelete(context),
                prefixIcon: Icons.delete_outline,
                foregroundColor: Theme.of(context).colorScheme.error,
                borderColor: Theme.of(
                  context,
                ).colorScheme.error.withValues(alpha: 0.3),
              ),
            ],
            SizedBox(height: dimensions.spacing.large.height),
          ],
        ),
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate() && _selectedCategory != null) {
      final balance = CurrencyInputFormatter.parse(_balanceController.text);
      final dueDay = int.tryParse(_dueDayController.text);

      widget.onSave(
        _nameController.text.trim(),
        _selectedCategory!,
        balance,
        dueDay,
      );

      Navigator.of(context).pop();
    }
  }

  void _onDelete(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.accountsDeleteAccount),
        content: Text(l10n.accountsConfirmDelete),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.profileCancel),
          ),
          TextButton(
            onPressed: () {
              if (widget.account != null) {
                context.read<AccountBloc>().add(
                  DeleteAccountEvent(widget.account!.id),
                );
              }
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Close bottom sheet
            },
            child: Text(
              l10n.profileExclude,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
}
