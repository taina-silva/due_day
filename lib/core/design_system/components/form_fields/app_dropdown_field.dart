import 'package:due_day/core/design_system/theme/theme.dart';
import 'package:flutter/material.dart';

class AppDropdownField<T> extends StatelessWidget {
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final String hintText;
  final String? label;
  final IconData? prefixIcon;
  final String? Function(T?)? validator;

  const AppDropdownField({
    required this.value,
    required this.items,
    required this.onChanged,
    required this.hintText,
    super.key,
    this.label,
    this.prefixIcon,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final dimensions = context.dimensions;

    return DropdownButtonFormField<T>(
      initialValue: value,
      items: items,
      onChanged: onChanged,
      validator: validator,
      style: typography.body.medium.copyWith(
        color: Theme.of(context).colorScheme.onSurface,
      ),
      icon: Icon(Icons.arrow_drop_down, color: colors.resource.secondary),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: typography.body.medium.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        labelText: label,
        labelStyle: typography.label.large.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: colors.resource.secondary)
            : null,
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(dimensions.radius.medium),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(dimensions.radius.medium),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(dimensions.radius.medium),
          borderSide: BorderSide(
            color: colors.resource.primary,
            width: dimensions.stroke.large,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(dimensions.radius.medium),
          borderSide: BorderSide(
            color: colors.system.error,
            width: dimensions.stroke.large,
          ),
        ),
        contentPadding: dimensions.spacing.paddingMedium,
      ),
      dropdownColor: Theme.of(context).colorScheme.surface,
    );
  }
}
