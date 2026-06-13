import 'package:due_day/core/design_system/theme/theme.dart';
import 'package:due_day/core/l10n/app_localizations.dart';
import 'package:due_day/core/utils/extensions/num_extension.dart';
import 'package:flutter/material.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeIn;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();

    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _scale = Tween<double>(
      begin: 0.82,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const colors = DueDayTheme.colors;
    const typography = DueDayTheme.typography;
    final size = DueDayTheme.dimensions.size;
    final spacing = DueDayTheme.dimensions.spacing;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: colors.resource.primary,
      body: Center(
        child: FadeTransition(
          opacity: _fadeIn,
          child: ScaleTransition(
            scale: _scale,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/logo/logo.png',
                  width: 104.scale,
                  height: 104.scale,
                ),
                SizedBox(height: spacing.mediumLarge.height),
                Text(
                  l10n.splashAppName,
                  style: typography.headline.large.copyWith(
                    color: colors.onDarkBackground,
                    fontSize: size.twoExtraLarge.fontSize,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                    height: 1,
                  ),
                ),
                SizedBox(height: spacing.small.height),
                Text(
                  l10n.splashTagline,
                  style: typography.body.medium.copyWith(
                    color: colors.onDarkBackground.withValues(alpha: 0.75),
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
