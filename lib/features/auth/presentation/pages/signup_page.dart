import 'package:due_day/core/design_system/components/buttons/app_text_button.dart';
import 'package:due_day/core/design_system/components/form_fields/app_text_field.dart';
import 'package:due_day/core/design_system/components/structure/custom_app_bar.dart';
import 'package:due_day/core/design_system/components/structure/custom_scaffold.dart';
import 'package:due_day/core/design_system/theme/theme.dart';
import 'package:due_day/core/l10n/app_localizations.dart';
import 'package:due_day/core/utils/extensions/num_extension.dart';
import 'package:due_day/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:due_day/features/auth/presentation/bloc/auth_event.dart';
import 'package:due_day/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const colors = DueDayTheme.colors;
    const typography = DueDayTheme.typography;
    final spacing = DueDayTheme.dimensions.spacing;
    final l10n = AppLocalizations.of(context);

    return CustomScaffold(
      appBar: const CustomAppBar(
        titleText: '',
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            context.go('/dashboard');
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.message,
                  style: typography.body.medium.copyWith(
                    color: colors.onDarkBackground,
                  ),
                ),
                backgroundColor: colors.system.error,
              ),
            );
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: spacing.largeExtraLarge.width,
              vertical: spacing.mediumLarge.height,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l10n.signupTitle, style: typography.headline.large),
                SizedBox(height: spacing.smallMedium.height),
                Text(
                  l10n.signupSubtitle,
                  style: typography.body.large.copyWith(
                    color: colors.resource.secondary,
                  ),
                ),
                SizedBox(height: spacing.threeExtraLarge.height),

                AppTextField(
                  controller: _nameController,
                  hintText: l10n.signupNameLabel,
                  prefixIcon: Icons.person_outline,
                ),
                SizedBox(height: spacing.mediumLarge.height),
                AppTextField(
                  controller: _emailController,
                  hintText: l10n.loginEmailLabel,
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: spacing.mediumLarge.height),
                AppTextField(
                  controller: _passwordController,
                  hintText: l10n.loginPasswordLabel,
                  prefixIcon: Icons.lock_outline,
                  obscureText: _obscurePassword,
                  suffixIcon: _obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  onSuffixIconPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
                SizedBox(height: spacing.twoExtraLarge.height),

                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    return AppTextButtonPrimary(
                      label: l10n.signupSubmitButton,
                      isLoading: state is AuthLoading,
                      onPressed: () {
                        final name = _nameController.text.trim();
                        final email = _emailController.text.trim();
                        final password = _passwordController.text.trim();
                        if (name.isNotEmpty &&
                            email.isNotEmpty &&
                            password.isNotEmpty) {
                          context.read<AuthBloc>().add(
                            AuthSignUpEmailEvent(
                              displayName: name,
                              email: email,
                              password: password,
                            ),
                          );
                        }
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
