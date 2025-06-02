import 'dart:async';
import 'package:image_picker/image_picker.dart';

/// Base image validator interface
abstract class ImageValidator {
  /// Validate an image and return true if valid
  Future<bool> validate(XFile image);

  /// Get error message for invalid images
  String get errorMessage;
}

/// Base image processor interface
abstract class ImageProcessor {
  /// Process an image and return the processed version
  Future<XFile> process(XFile image, bool isMultiple, int index);

  /// Whether this processor should run on this image
  FutureOr<bool> shouldProcess(XFile image, bool isMultiple, int index);
}
