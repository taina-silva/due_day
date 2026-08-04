import 'package:due_day/core/design_system/components/buttons/app_text_button.dart';
import 'package:due_day/core/design_system/components/messenger/app_messenger.dart';
import 'package:due_day/core/design_system/theme/theme.dart';
import 'package:due_day/core/l10n/app_localizations.dart';
import 'package:due_day/core/utils/extensions/num_extension.dart';
import 'package:due_day/features/auth/domain/entities/user_entity.dart';
import 'package:due_day/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:due_day/features/auth/presentation/bloc/auth_event.dart';
import 'package:due_day/features/auth/presentation/utils/auth_failure_extension.dart';
import 'package:due_day/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:due_day/features/profile/presentation/bloc/profile_event.dart';
import 'package:due_day/features/profile/presentation/bloc/profile_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

class ChangePhotoBottomSheet extends StatefulWidget {
  final UserEntity currentUser;

  const ChangePhotoBottomSheet({required this.currentUser, super.key});

  @override
  State<ChangePhotoBottomSheet> createState() => _ChangePhotoBottomSheetState();
}

class _ChangePhotoBottomSheetState extends State<ChangePhotoBottomSheet> {
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final dimensions = context.dimensions;
    final typography = context.typography;
    final colors = context.colors;
    final l10n = AppLocalizations.of(context);

    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (!_isSubmitting) return;

        if (state is ProfileActionError) {
          setState(() => _isSubmitting = false);
          AppMessenger.showError(
            context,
            state.failure.toLocalizedString(
              context,
              fallbackContext: AuthFallbackContext.profile,
            ),
          );
        } else if (state is ProfileActionSuccess) {
          _isSubmitting = false;
          context.read<AuthBloc>().add(AuthUserRefreshed(state.user));
          Navigator.of(context).pop();
        }
      },
      child: Padding(
        padding: EdgeInsets.only(
          bottom:
              MediaQuery.of(context).viewInsets.bottom +
              dimensions.spacing.large.height,
          left: dimensions.spacing.medium.width,
          right: dimensions.spacing.medium.width,
          top: dimensions.spacing.large.height,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40.width,
                height: 4.height,
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
              l10n.profileChangePhoto,
              style: typography.title.large.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: dimensions.spacing.extraLarge.height),
            AppTextButtonPrimary(
              label: l10n.profileTakePhoto,
              onPressed: () => _pickImage(ImageSource.camera),
              prefixIcon: Icons.photo_camera_outlined,
              isLoading: _isSubmitting,
            ),
            SizedBox(height: dimensions.spacing.medium.height),
            AppTextButtonSecondary(
              label: l10n.profileChooseFromGallery,
              onPressed: () => _pickImage(ImageSource.gallery),
              prefixIcon: Icons.photo_library_outlined,
              foregroundColor: colors.resource.primary,
            ),
          ],
        ),
      ),
    );
  }

  void _pickImage(ImageSource source) {
    setState(() => _isSubmitting = true);
    context.read<ProfileBloc>().add(
      ProfilePictureRequested(source: source, currentUser: widget.currentUser),
    );
  }
}
