import 'dart:ui';
import 'package:due_day/core/design_system/theme/theme.dart';
import 'package:due_day/core/utils/extensions/num_extension.dart';
import 'package:flutter/material.dart';

class BiometricLockOverlay extends StatelessWidget {
  final VoidCallback onAuthenticate;

  const BiometricLockOverlay({
    required this.onAuthenticate,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final spacing = context.spacing;
    final radius = context.radius;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.black.withValues(alpha: 0.7),
        body: Stack(
          children: [
            // Efeito blur no fundo da UI existente
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
                child: Container(
                  color: Colors.transparent,
                ),
              ),
            ),
            // Conteúdo principal
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: spacing.threeExtraLarge.width),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo com pulso animado ou visual seguro
                    Container(
                      padding: EdgeInsets.all(spacing.largeExtraLarge.width),
                      decoration: BoxDecoration(
                        color: colors.resource.primary.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colors.resource.primary.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.lock_outline_rounded,
                        color: colors.resource.primary,
                        size: 64.scale,
                      ),
                    ),
                    SizedBox(height: spacing.threeExtraLarge.height),
                    Text(
                      'Acesso Bloqueado',
                      textAlign: TextAlign.center,
                      style: typography.headline.large.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: spacing.mediumLarge.height),
                    Text(
                      'Sua privacidade é nossa prioridade. Para acessar o DueDay, confirme sua identidade utilizando biometria.',
                      textAlign: TextAlign.center,
                      style: typography.body.medium.copyWith(
                        color: Colors.white.withValues(alpha: 0.7),
                        height: 1.4,
                      ),
                    ),
                    SizedBox(height: spacing.threeExtraLarge.height),
                    // Botão de Autenticação com o design system do app
                    InkWell(
                      onTap: onAuthenticate,
                      borderRadius: BorderRadius.circular(radius.extraLarge),
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          vertical: spacing.large.height,
                        ),
                        decoration: BoxDecoration(
                          color: colors.resource.primary,
                          borderRadius: BorderRadius.circular(radius.extraLarge),
                          boxShadow: [
                            BoxShadow(
                              color: colors.resource.primary.withValues(alpha: 0.4),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            'Desbloquear Aplicativo',
                            style: typography.body.large.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
