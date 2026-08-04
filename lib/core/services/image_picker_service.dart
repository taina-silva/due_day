import 'dart:convert';

import 'package:due_day/core/observability/observability_service.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

const int _maxAvatarDimension = 512;
const int _avatarJpegQuality = 70;
const int _maxEncodedImageLength = 900000;

sealed class ImagePickResult {
  const ImagePickResult();
}

class ImagePickSuccess extends ImagePickResult {
  final String base64Image;

  const ImagePickSuccess(this.base64Image);
}

class ImagePickCanceled extends ImagePickResult {
  const ImagePickCanceled();
}

class ImagePickTooLarge extends ImagePickResult {
  const ImagePickTooLarge();
}

class ImagePickFailed extends ImagePickResult {
  const ImagePickFailed();
}

/// Encodes raw JPEG bytes into a `data:image/jpeg;base64,...` string, or
/// returns [ImagePickTooLarge] if the encoded string would risk breaching
/// Firestore's 1 MiB document size limit.
ImagePickResult encodeAvatarImage(Uint8List bytes) {
  final String encoded = base64Encode(bytes);
  if (encoded.length > _maxEncodedImageLength) {
    return const ImagePickTooLarge();
  }
  return ImagePickSuccess('data:image/jpeg;base64,$encoded');
}

abstract class ImagePickerService {
  Future<ImagePickResult> pickImage(ImageSource source);
}

class ImagePickerServiceImpl implements ImagePickerService {
  final ImagePicker picker;
  final ObservabilityService observability;

  ImagePickerServiceImpl({required this.picker, required this.observability});

  @override
  Future<ImagePickResult> pickImage(ImageSource source) async {
    try {
      final XFile? file = await picker.pickImage(
        source: source,
        maxWidth: _maxAvatarDimension.toDouble(),
        maxHeight: _maxAvatarDimension.toDouble(),
        imageQuality: _avatarJpegQuality,
      );
      if (file == null) {
        return const ImagePickCanceled();
      }
      final Uint8List bytes = await file.readAsBytes();
      return encodeAvatarImage(bytes);
    } on PlatformException catch (e, stackTrace) {
      observability.warning(
        'Failed to pick profile image',
        tag: 'profile',
        error: e,
        stackTrace: stackTrace,
      );
      return const ImagePickFailed();
    } catch (e, stackTrace) {
      observability.error(
        'Unexpected error picking profile image',
        tag: 'profile',
        error: e,
        stackTrace: stackTrace,
      );
      return const ImagePickFailed();
    }
  }
}
