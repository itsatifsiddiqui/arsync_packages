import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

import '../core/config.dart';
import '../core/image_picker_service.dart';
import '../core/interfaces.dart';

/// A processor for converting images to specific formats
class FormatConverterProcessor implements ImageProcessor {
  final ImageFormatType targetFormat;

  FormatConverterProcessor({required this.targetFormat});

  @override
  Future<bool> shouldProcess(XFile image, _, _) async {
    if (targetFormat == ImageFormatType.original) return false;

    final extension = ArsyncImagePicker.getFileExtension(image.path);

    // Check if already in target format
    if (targetFormat == ImageFormatType.png && extension == '.png') {
      return false;
    }

    if (targetFormat == ImageFormatType.jpg &&
        (extension == '.jpg' || extension == '.jpeg')) {
      return false;
    }

    return true;
  }

  @override
  Future<XFile> process(XFile image, _, _) async {
    // Read the image bytes
    final imageBytes = await image.readAsBytes();

    // Decode the image
    final decodedImage = await compute(img.decodeImage, imageBytes);
    if (decodedImage == null) {
      throw Exception('Failed to decode image');
    }

    // Create new file path
    final directory = path.dirname(image.path);
    final nameWithoutExtension = path.basenameWithoutExtension(image.path);
    final extension = targetFormat == ImageFormatType.png ? '.png' : '.jpg';
    final newPath = path.join(directory, '$nameWithoutExtension$extension');

    // Encode to target format
    Uint8List encodedBytes;
    if (targetFormat == ImageFormatType.png) {
      encodedBytes = await compute(img.encodePng, decodedImage);
    } else {
      encodedBytes = await compute(
        (img.Image image) => img.encodeJpg(image),
        decodedImage,
      );
    }

    // Write the new file
    await XFile.fromData(
      encodedBytes,
      mimeType: 'image/$extension',
    ).saveTo(newPath);

    return XFile(newPath);
  }
}
