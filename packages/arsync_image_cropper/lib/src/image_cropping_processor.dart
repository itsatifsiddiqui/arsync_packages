import 'dart:async';

import 'package:cross_file/cross_file.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:arsync_image_picker/arsync_image_picker.dart';

import 'crop_options.dart';

/// A processor for cropping images
class ImageCroppingProcessor implements ImageProcessor {
  final CropOptions options;
  final int quality;

  ImageCroppingProcessor({
    this.options = const CropOptions(),
    this.quality = 50,
  });

  @override
  FutureOr<bool> shouldProcess(XFile image, _, _) => true;

  @override
  Future<XFile> process(XFile image, _, _) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: image.path,
      aspectRatio: options.aspectRatio,
      compressQuality: quality,
      uiSettings:
          options.uiSettings ??
          [
            AndroidUiSettings(
              initAspectRatio:
                  options.aspectRatioPresets?.first ??
                  CropAspectRatioPreset.original,
              lockAspectRatio:
                  options.lockAspectRatio || options.aspectRatio != null,
              hideBottomControls: options.aspectRatio != null,
              aspectRatioPresets:
                  options.aspectRatioPresets ??
                  [
                    CropAspectRatioPreset.original,
                    CropAspectRatioPreset.square,
                    CropAspectRatioPreset.ratio3x2,
                    CropAspectRatioPreset.ratio4x3,
                    CropAspectRatioPreset.ratio16x9,
                  ],
            ),
            IOSUiSettings(
              title: options.title,
              aspectRatioLockEnabled:
                  options.lockAspectRatio || options.aspectRatio != null,
              aspectRatioPickerButtonHidden: options.aspectRatio != null,
              aspectRatioPresets:
                  options.aspectRatioPresets ??
                  [
                    CropAspectRatioPreset.original,
                    CropAspectRatioPreset.square,
                    CropAspectRatioPreset.ratio3x2,
                    CropAspectRatioPreset.ratio4x3,
                    CropAspectRatioPreset.ratio16x9,
                  ],
            ),
          ],
    );

    return croppedFile != null ? XFile(croppedFile.path) : image;
  }
}
