import 'package:due_day/core/design_system/components/structure/custom_app_bar.dart';
import 'package:due_day/core/design_system/components/structure/custom_scaffold.dart';
import 'package:due_day/core/design_system/theme/theme.dart';
import 'package:due_day/core/l10n/app_localizations.dart';
import 'package:due_day/core/utils/app_constants.dart';
import 'package:due_day/core/utils/extensions/num_extension.dart';
import 'package:due_day/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:due_day/features/auth/presentation/bloc/auth_state.dart';
import 'package:due_day/features/profile/presentation/widgets/account/account_actions.dart';
import 'package:due_day/features/profile/presentation/widgets/header/profile_avatar.dart';
import 'package:due_day/features/profile/presentation/widgets/header/profile_info.dart';
import 'package:due_day/features/profile/presentation/widgets/settings/language_selector.dart';
import 'package:due_day/features/profile/presentation/widgets/settings/notification_settings.dart';
import 'package:due_day/features/profile/presentation/widgets/settings/security_block.dart';
import 'package:due_day/features/profile/presentation/widgets/settings/theme_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final spacing = DueDayTheme.dimensions.spacing;
    final l10n = AppLocalizations.of(context);

    // Ensure state provides user info
    String userName = l10n.profileDefaultUserName;
    String userEmail = '';
    String initials = 'U';

    final authState = context.read<AuthBloc>().state;

    if (authState is AuthAuthenticated) {
      userName = authState.user.name ?? l10n.profileDefaultUserName;
      userEmail = authState.user.email;
      if (userName.isNotEmpty) {
        final parts = userName.split(' ');
        if (parts.length > 1) {
          initials = '${parts[0][0]}${parts[1][0]}'.toUpperCase();
        } else {
          initials = userName.substring(0, 1).toUpperCase();
        }
      }
    }

    return CustomScaffold(
      appBar: CustomAppBar(titleText: l10n.profileTitle),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: spacing.largeExtraLarge.width,
          vertical: spacing.mediumLarge.height,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Profile Header
            Column(
              children: [
                ProfileAvatar(initials: initials),
                ProfileInfo(userName: userName, userEmail: userEmail),
              ],
            ),

            SizedBox(height: spacing.threeExtraLarge.height),

            // Settings List
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const LanguageSelector(),
                SizedBox(
                  height: DueDayTheme.dimensions.spacing.mediumLarge.height,
                ),
                const ThemeSelector(),
                SizedBox(
                  height: DueDayTheme.dimensions.spacing.mediumLarge.height,
                ),
                const NotificationSettings(),
              ],
            ),

            SizedBox(height: spacing.mediumLarge.height),

            // Account Actions
            const AccountActions(),

            SizedBox(height: spacing.mediumLarge.height),

            // Security Block
            const SecurityBlock(),

            SizedBox(
              height: AppConstants.bottomSafeArea(
                context,
                padding: spacing.mediumLarge.height,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
