import 'dart:async';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

import '../../../src/ui/ui_providers.dart';
import 'config.dart';
import 'interfaces.dart';

/// Core image picker service without external dependencies
class ArsyncImagePickerService {
  XFile? imageFile;

  /// UI configuration
  final ImagePickerUIConfig uiConfig;

  /// App name
  final String appname;

  /// List of image validators
  final List<ImageValidator> validators;

  /// List of image processors
  final List<ImageProcessor> processors;

  /// UI provider
  final ImagePickerUIProvider uiProvider;

  ArsyncImagePickerService({
    ImagePickerUIConfig? uiConfig,
    List<ImageValidator>? validators,
    List<ImageProcessor>? processors,
    ImagePickerUIProvider? uiProvider,
    this.appname = 'This app',
  }) : uiConfig = uiConfig ?? const ImagePickerUIConfig(),
       validators = validators ?? [],
       processors = processors ?? [],
       uiProvider = uiProvider ?? DefaultImagePickerUI();

  /// Add a validator to the pipeline
  void addValidator(ImageValidator validator) {
    validators.add(validator);
  }

  /// Add a processor to the pipeline
  void addProcessor(ImageProcessor processor) {
    processors.add(processor);
  }

  /// Pick a single image
  Future<XFile?> pickImage({
    required BuildContext context,
    ImagePickerUIConfig? uiConfig,
    Function? onRemove,
    Function? onImageSelected,
  }) async {
    final images = await _showImagePickerUI(
      context: context,
      allowMultiple: false,
      uiConfig: uiConfig,
      onRemove: onRemove,
    );

    if (images == null) return null;
    if (!context.mounted) return null;

    final processedImages = await processSelectedImages(
      images,
      context,
      onImageSelected,
    );

    if (processedImages == null) return null;

    imageFile = processedImages.first;
    return imageFile;
  }

  /// Pick multiple images
  Future<List<XFile>?> pickImages({
    required BuildContext context,
    ImagePickerUIConfig? uiConfig,
    Function? onRemove,
    Function? onImagesSelected,
  }) async {
    final images = await _showImagePickerUI(
      context: context,
      allowMultiple: true,
      uiConfig: uiConfig,
      onRemove: onRemove,
    );

    if (images == null) return null;
    if (!context.mounted) return null;

    return processSelectedImages(images, context, onImagesSelected);
  }

  /// Pick a single image from gallery
  Future<XFile?> pickImageFromGallery({
    required BuildContext context,
    Function? onImageSelected,
  }) async {
    final images = await _chooseFromPhotos(context, false, appname);

    if (images == null) return null;
    if (!context.mounted) return null;

    final processedImages = await processSelectedImages(
      images,
      context,
      onImageSelected,
    );

    if (processedImages == null) return null;

    imageFile = processedImages.first;
    return imageFile;
  }

  /// Pick multiple images from gallery
  Future<List<XFile>?> pickImagesFromGallery({
    required BuildContext context,
    Function? onImagesSelected,
  }) async {
    final images = await _chooseFromPhotos(context, true, appname);

    if (images == null) return null;
    if (!context.mounted) return null;

    return processSelectedImages(images, context, onImagesSelected);
  }

  /// Pick a single image from camera
  Future<XFile?> pickImageFromCamera({
    required BuildContext context,
    Function? onImageSelected,
  }) async {
    final image = await _takePhoto(context, appname);

    if (image == null) return null;
    if (!context.mounted) return null;

    final processedImages = await processSelectedImages(
      [image],
      context,
      onImageSelected,
    );

    if (processedImages == null) return null;

    imageFile = processedImages.first;
    return imageFile;
  }

  Future<List<XFile>?> processSelectedImages(
    List<XFile>? images,
    BuildContext context,
    Function? onImageSelected,
  ) async {
    if (images == null) return null;

    onImageSelected?.call();

    final processedImages = await _processAndValidateImages(
      context: context,
      images: images,
      isMultiple: images.length > 1,
    );

    if (processedImages.isEmpty) return null;

    return processedImages;
  }

  /// Process and validate images through the pipeline
  Future<List<XFile>> _processAndValidateImages({
    required BuildContext context,
    required List<XFile> images,
    required bool isMultiple,
  }) async {
    List<XFile> processedImages = List.from(images);

    // Run all processors on each image
    for (int i = 0; i < processedImages.length; i++) {
      XFile currentImage = processedImages[i];

      for (final processor in processors) {
        if (await processor.shouldProcess(currentImage, isMultiple, i)) {
          try {
            currentImage = await processor.process(currentImage, isMultiple, i);
          } catch (e) {
            debugPrint('Image processing error: $e');
            // Continue with original image if processing fails
          }
        }
      }

      processedImages[i] = currentImage;
    }

    // Run all validators on each processed image
    final validImages = <XFile>[];
    for (final image in processedImages) {
      bool isValid = true;

      for (final validator in validators) {
        if (!await validator.validate(image)) {
          isValid = false;
          debugPrint('Image validation failed: ${validator.errorMessage}');
          break;
        }
      }

      if (isValid) {
        validImages.add(image);
      }
    }

    return validImages;
  }

  /// Show the image picker UI
  Future<List<XFile>?> _showImagePickerUI({
    required BuildContext context,
    required bool allowMultiple,
    ImagePickerUIConfig? uiConfig,
    Function? onRemove,
  }) async {
    return await uiProvider.showImagePickerUI(
      context: context,
      allowMultiple: allowMultiple,
      config: uiConfig ?? this.uiConfig,
      onRemove: onRemove,
      appname: appname,
      chooseFromPhotos: _chooseFromPhotos,
      takePhoto: _takePhoto,
    );
  }

  /// Choose from photos
  Future<List<XFile>?> _chooseFromPhotos(
    BuildContext context,
    bool allowMultiples,
    String appname,
  ) async {
    if (allowMultiples) {
      final pickedImages = await ImagePicker().pickMultiImage(imageQuality: 20);
      if (pickedImages.isEmpty) return null;
      return pickedImages;
    } else {
      final pickedImage = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 20,
      );
      if (pickedImage == null) return null;
      return [pickedImage];
    }
  }

  /// Take a photo
  Future<XFile?> _takePhoto(BuildContext context, String appname) async {
    final pickedImage = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 20,
    );
    if (pickedImage == null) return null;
    return pickedImage;
  }

  /// Get the extension of an image file
  static String getFileExtension(String filePath) {
    return path.extension(filePath).toLowerCase();
  }

  /// Get the size of a file in MB
  static Future<double> getFileSizeMB(XFile file) async {
    final bytes = await file.length();
    return bytes / (1024 * 1024);
  }

  /// print the size of a file in MB
  static void printFileSizeMB(XFile file) {
    getFileSizeMB(
      file,
    ).then((value) => debugPrint('File size: ${value.toStringAsFixed(2)} MB'));
  }

  /// print the extension of a file
  static void printFileExtension(XFile file) {
    debugPrint('File extension: ${getFileExtension(file.path)}');
  }
}
