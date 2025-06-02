import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';

/// Options for image cropping
class CropOptions {
  final CropAspectRatio? aspectRatio;
  final List<CropAspectRatioPreset>? aspectRatioPresets;
  final bool lockAspectRatio;
  final String title;
  final Color? toolbarColor;
  final List<PlatformUiSettings>? uiSettings;

  const CropOptions({
    this.aspectRatio,
    this.aspectRatioPresets,
    this.lockAspectRatio = false,
    this.title = 'Crop Image',
    this.toolbarColor,
    this.uiSettings,
  });
}
