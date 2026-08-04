import 'dart:convert';

import 'package:due_day/core/observability/observability_service.dart';
import 'package:due_day/core/services/image_picker_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mocktail/mocktail.dart';

class MockImagePicker extends Mock implements ImagePicker {}

void main() {
  group('encodeAvatarImage', () {
    test('given small image bytes when encodeAvatarImage is called then return '
        'ImagePickSuccess with a data:image/jpeg;base64, prefix', () {
      final bytes = Uint8List.fromList([1, 2, 3, 4, 5]);

      final result = encodeAvatarImage(bytes);

      expect(result, isA<ImagePickSuccess>());
      final success = result as ImagePickSuccess;
      expect(
        success.base64Image,
        'data:image/jpeg;base64,${base64Encode(bytes)}',
      );
    });

    test('given bytes that base64-encode past 900,000 characters when '
        'encodeAvatarImage is called then return ImagePickTooLarge', () {
      final bytes = Uint8List(700000);

      final result = encodeAvatarImage(bytes);

      expect(result, isA<ImagePickTooLarge>());
    });

    test('given bytes that base64-encode to exactly the limit when '
        'encodeAvatarImage is called then return ImagePickSuccess', () {
      // 3 raw bytes -> 4 base64 chars, no padding. 675000 * 4 / 3 = 900000.
      final bytes = Uint8List(675000);

      final result = encodeAvatarImage(bytes);

      expect(result, isA<ImagePickSuccess>());
      final success = result as ImagePickSuccess;
      expect(
        success.base64Image.length,
        900000 + 'data:image/jpeg;base64,'.length,
      );
    });
  });

  group('ImagePickerServiceImpl.pickImage', () {
    late MockImagePicker mockPicker;
    late ObservabilityService observability;
    late ImagePickerServiceImpl service;

    setUpAll(() {
      registerFallbackValue(ImageSource.camera);
    });

    setUp(() {
      mockPicker = MockImagePicker();
      observability = ObservabilityServiceImpl(sinks: const []);
      service = ImagePickerServiceImpl(
        picker: mockPicker,
        observability: observability,
      );
    });

    test('given the picker returns null when pickImage is called then return '
        'ImagePickCanceled', () async {
      when(
        () => mockPicker.pickImage(
          source: any(named: 'source'),
          maxWidth: any(named: 'maxWidth'),
          maxHeight: any(named: 'maxHeight'),
          imageQuality: any(named: 'imageQuality'),
        ),
      ).thenAnswer((_) async => null);

      final result = await service.pickImage(ImageSource.gallery);

      expect(result, isA<ImagePickCanceled>());
    });

    test('given the picker returns a small XFile when pickImage is called then '
        'return ImagePickSuccess with the encoded image', () async {
      final bytes = Uint8List.fromList([9, 8, 7, 6]);
      final file = XFile.fromData(bytes, name: 'test.jpg');
      when(
        () => mockPicker.pickImage(
          source: any(named: 'source'),
          maxWidth: any(named: 'maxWidth'),
          maxHeight: any(named: 'maxHeight'),
          imageQuality: any(named: 'imageQuality'),
        ),
      ).thenAnswer((_) async => file);

      final result = await service.pickImage(ImageSource.camera);

      expect(result, isA<ImagePickSuccess>());
      final success = result as ImagePickSuccess;
      expect(
        success.base64Image,
        'data:image/jpeg;base64,${base64Encode(bytes)}',
      );
    });

    test('given the picker calls pickImage when invoked then use the avatar '
        'resize/quality constraints', () async {
      when(
        () => mockPicker.pickImage(
          source: any(named: 'source'),
          maxWidth: any(named: 'maxWidth'),
          maxHeight: any(named: 'maxHeight'),
          imageQuality: any(named: 'imageQuality'),
        ),
      ).thenAnswer((_) async => null);

      await service.pickImage(ImageSource.camera);

      verify(
        () => mockPicker.pickImage(
          source: ImageSource.camera,
          maxWidth: 512,
          maxHeight: 512,
          imageQuality: 70,
        ),
      ).called(1);
    });

    test('given the picker throws a PlatformException when pickImage is called '
        'then return ImagePickFailed', () async {
      when(
        () => mockPicker.pickImage(
          source: any(named: 'source'),
          maxWidth: any(named: 'maxWidth'),
          maxHeight: any(named: 'maxHeight'),
          imageQuality: any(named: 'imageQuality'),
        ),
      ).thenThrow(PlatformException(code: 'camera_access_denied'));

      final result = await service.pickImage(ImageSource.camera);

      expect(result, isA<ImagePickFailed>());
    });

    test('given the picker throws an unexpected exception when pickImage is '
        'called then return ImagePickFailed', () async {
      when(
        () => mockPicker.pickImage(
          source: any(named: 'source'),
          maxWidth: any(named: 'maxWidth'),
          maxHeight: any(named: 'maxHeight'),
          imageQuality: any(named: 'imageQuality'),
        ),
      ).thenThrow(Exception('unexpected'));

      final result = await service.pickImage(ImageSource.gallery);

      expect(result, isA<ImagePickFailed>());
    });
  });
}
