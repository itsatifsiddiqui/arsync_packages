import 'dart:async';
import 'dart:io';

import 'package:arsync_image_picker/arsync_image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as path;

/// A processor that compresses images to reduce file size
class ImageCompressionProcessor implements ImageProcessor {
  final double targetMaxSizeMB;
  final int quality;
  final int minQuality;
  final int maxAttempts;

  ImageCompressionProcessor({
    required this.targetMaxSizeMB,
    this.quality = 80,
    this.minQuality = 10,
    this.maxAttempts = 3,
  });

  @override
  FutureOr<bool> shouldProcess(XFile image, _, _) async {
    // Only compress if the file is larger than the target size
    final currentSize = await ArsyncImagePicker.getFileSizeMB(image);
    return currentSize > targetMaxSizeMB;
  }

  @override
  Future<XFile> process(XFile image, _, _) async {
    final extension = ArsyncImagePicker.getFileExtension(image.path);
    CompressFormat format;

    if (extension == '.png') {
      format = CompressFormat.png;
    } else {
      format = CompressFormat.jpeg;
    }

    XFile currentImage = image;
    int currentQuality = quality;
    int attempts = 0;

    while (attempts < maxAttempts) {
      // Check if the image is already small enough
      final currentSize = await ArsyncImagePicker.getFileSizeMB(
        currentImage,
      );
      if (currentSize <= targetMaxSizeMB) {
        break;
      }

      // Create a temporary file path for compression
      final dir = path.dirname(currentImage.path);
      final filename = path.basenameWithoutExtension(currentImage.path);
      final tempPath = path.join(dir, '${filename}_temp$extension');

      try {
        // Compress the image to temporary path
        final result = await FlutterImageCompress.compressAndGetFile(
          currentImage.path,
          tempPath,
          quality: currentQuality,
          format: format,
        );

        if (result != null) {
          // Replace original file with compressed version
          final compressedFile = File(tempPath);
          final originalPath = currentImage.path;

          // Copy compressed file to original path
          await compressedFile.copy(originalPath);

          // Delete the temporary file
          await compressedFile.delete();

          // Clean up any intermediate file if it's not the original
          if (currentImage.path != image.path) {
            try {
              await File(currentImage.path).delete();
            } catch (e) {
              debugPrint('Error deleting intermediate file: $e');
            }
          }

          currentImage = XFile(originalPath);
        } else {
          // Compression failed, break the loop
          break;
        }
      } catch (e) {
        debugPrint('Error during compression: $e');
        break;
      }

      // Reduce quality for next attempt
      currentQuality = (currentQuality * 0.7).round();
      if (currentQuality < minQuality) {
        currentQuality = minQuality;
      }

      attempts++;
    }

    return currentImage;
  }

  Future<XFile> processWithCheck(XFile image) async {
    if (!(await shouldProcess(image, false, 0))) return image;
    return process(image, false, 0);
  }
}
