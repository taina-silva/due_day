import 'package:due_day/core/design_system/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String? label;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final int maxLines;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final bool enableSuggestions;
  final bool autocorrect;
  final TextCapitalization textCapitalization;
  final VoidCallback? onSuffixIconPressed;

  final int? maxLength;

  const AppTextField({
    required this.controller,
    required this.hintText,
    super.key,
    this.label,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.maxLines = 1,
    this.validator,
    this.inputFormatters,
    this.enableSuggestions = true,
    this.autocorrect = true,
    this.textCapitalization = TextCapitalization.none,
    this.onSuffixIconPressed,
    this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final dimensions = context.dimensions;

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType ?? TextInputType.text,
      maxLines: maxLines,
      maxLength: maxLength,
      validator: validator,
      inputFormatters: inputFormatters,
      enableSuggestions: enableSuggestions,
      autocorrect: autocorrect,
      textCapitalization: textCapitalization,
      enableIMEPersonalizedLearning: true,
      style: typography.body.medium,
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
        suffixIcon: suffixIcon != null
            ? (onSuffixIconPressed != null
                  ? IconButton(
                      icon: Icon(suffixIcon, color: colors.resource.secondary),
                      onPressed: onSuffixIconPressed,
                    )
                  : Icon(suffixIcon, color: colors.resource.secondary))
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
    );
  }
}
