import 'package:arsync_image_picker/arsync_image_picker.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SuperImagePickerService', () {
    test('should initialize with default config', () {
      final service = ArsyncImagePickerService();
      expect(service.validators, isEmpty);
      expect(service.processors, isEmpty);
      expect(service.appname, 'This app');
    });

    test('should add validators and processors', () {
      final service = ArsyncImagePickerService();
      final validator = FileSizeValidator(maxSizeMB: 5.0);
      final processor = FileNameProcessor(newFileName: 'test');

      service.addValidator(validator);
      service.addProcessor(processor);

      expect(service.validators.length, 1);
      expect(service.processors.length, 1);
    });

    test('should create custom config', () {
      const config = ImagePickerUIConfig(
        title: 'Custom Title',
        galleryButtonText: 'Custom Gallery',
      );

      expect(config.title, 'Custom Title');
      expect(config.galleryButtonText, 'Custom Gallery');
      expect(config.cameraButtonText, 'Take Photo'); // default
    });
  });

  group('FileSizeValidator', () {
    test('should have correct error message', () {
      final validator = FileSizeValidator(maxSizeMB: 5.0);
      expect(validator.errorMessage, 'File size exceeds the limit of 5.0 MB');
    });

    test('should accept custom error message', () {
      final validator = FileSizeValidator(
        maxSizeMB: 5.0,
        errorMessage: 'Custom error',
      );
      expect(validator.errorMessage, 'Custom error');
    });
  });
}
