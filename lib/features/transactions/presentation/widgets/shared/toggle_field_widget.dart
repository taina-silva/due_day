import 'package:due_day/core/design_system/theme/theme.dart';
import 'package:due_day/core/utils/extensions/num_extension.dart';
import 'package:flutter/material.dart';

class TransactionToggleField extends StatelessWidget {
  final String label;
  final String valueLabel;
  final bool isOn;
  final ValueChanged<bool> onChanged;

  const TransactionToggleField({
    required this.label,
    required this.valueLabel,
    required this.isOn,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final typography = context.typography;
    final radius = context.radius;

    return Container(
      padding: EdgeInsets.all(spacing.medium.width),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(radius.medium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: typography.label.small.copyWith(
              color: colors.resource.secondary,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(valueLabel, style: typography.body.medium),
              Switch(
                value: isOn,
                onChanged: onChanged,
                activeTrackColor: colors.resource.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
