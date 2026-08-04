import 'package:due_day/core/design_system/components/structure/custom_app_bar.dart';
import 'package:due_day/core/design_system/components/structure/custom_scaffold.dart';
import 'package:due_day/core/design_system/theme/theme.dart';
import 'package:due_day/core/l10n/app_localizations.dart';
import 'package:due_day/core/utils/app_constants.dart';
import 'package:due_day/core/utils/extensions/num_extension.dart';
import 'package:due_day/features/auth/domain/entities/user_entity.dart';
import 'package:due_day/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:due_day/features/auth/presentation/bloc/auth_state.dart';
import 'package:due_day/features/profile/presentation/widgets/account/account_actions.dart';
import 'package:due_day/features/profile/presentation/widgets/bottom_sheets/change_photo_bottom_sheet.dart';
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
    final spacing = context.spacing;
    final l10n = AppLocalizations.of(context);

    String userName = l10n.profileDefaultUserName;
    String userEmail = '';
    String initials = 'U';
    UserEntity? user;

    final authState = context.watch<AuthBloc>().state;

    if (authState is AuthAuthenticated) {
      user = authState.user;
      userName = user.name ?? l10n.profileDefaultUserName;
      userEmail = user.email;
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
                ProfileAvatar(
                  initials: initials,
                  photoUrl: user?.photoUrl,
                  onTap: user == null
                      ? null
                      : () => showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          useRootNavigator: true,
                          builder: (_) =>
                              ChangePhotoBottomSheet(currentUser: user!),
                        ),
                ),
                ProfileInfo(userName: userName, userEmail: userEmail),
              ],
            ),

            SizedBox(height: spacing.threeExtraLarge.height),

            // Settings List
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const LanguageSelector(),
                SizedBox(height: context.spacing.mediumLarge.height),
                const ThemeSelector(),
                SizedBox(height: context.spacing.mediumLarge.height),
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
