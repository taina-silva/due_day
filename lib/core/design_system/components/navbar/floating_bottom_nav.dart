import 'dart:ui';

import 'package:due_day/core/design_system/theme/theme.dart';
import 'package:due_day/core/l10n/app_localizations.dart';
import 'package:due_day/core/utils/app_constants.dart';
import 'package:due_day/core/utils/extensions/num_extension.dart';
import 'package:flutter/material.dart';

class FloatingBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const FloatingBottomNav({
    required this.currentIndex,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final radius = context.radius;
    final l10n = AppLocalizations.of(context);

    return Container(
      margin: EdgeInsets.only(
        left: spacing.largeExtraLarge.width,
        right: spacing.largeExtraLarge.width,
        bottom: spacing.twoExtraLarge.height,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius.circle),
        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(0, 0, 0, 0.04),
            blurRadius: 40.width,
            offset: Offset(0, 20.height),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius.circle),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20.width, sigmaY: 20.height),
          child: Container(
            height: AppConstants.bottomNavHeight,
            padding: EdgeInsets.symmetric(
              horizontal: spacing.mediumLarge.width,
            ),
            color: Theme.of(context).colorScheme.surface.withValues(
              alpha: 0.8,
            ), // surface at 80% opacity
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home_rounded,
                  label: l10n.navHome,
                  isSelected: currentIndex == 0,
                  onTap: () => onTap(0),
                ),
                _NavItem(
                  icon: Icons.add_circle_outline_rounded,
                  activeIcon: Icons.add_circle_rounded,
                  label: l10n.navAdd,
                  isSelected: currentIndex == 1,
                  onTap: () => onTap(1),
                ),
                _NavItem(
                  icon: Icons.account_balance_wallet_outlined,
                  activeIcon: Icons.account_balance_wallet_rounded,
                  label: l10n.navAccount,
                  isSelected: currentIndex == 2,
                  onTap: () => onTap(2),
                ),
                _NavItem(
                  icon: Icons.grid_view_outlined,
                  activeIcon: Icons.grid_view_rounded,
                  label: l10n.navCategory,
                  isSelected: currentIndex == 3,
                  onTap: () => onTap(3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;
    final radius = context.radius;
    final size = context.sizes;

    final color = isSelected
        ? colors.resource.primary
        : colors.resource.secondary;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: spacing.medium.width,
          vertical: spacing.smallMedium.height,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? colors.resource.primaryWith15Opacity
              : Colors.transparent,
          borderRadius: BorderRadius.circular(radius.circle),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: color,
              size: size.iconMedium,
            ),
            if (isSelected) ...[
              SizedBox(width: spacing.smallMedium.width),
              Text(
                label,
                style: typography.label.medium.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
