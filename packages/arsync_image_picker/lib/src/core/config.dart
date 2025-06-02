/// Supported image format types
enum ImageFormatType { jpg, png, original }

/// Image picker UI settings
class ImagePickerUIConfig {
  final String title;
  final String galleryButtonText;
  final String cameraButtonText;
  final String cancelButtonText;
  final String removeButtonText;

  const ImagePickerUIConfig({
    this.title = 'Choose an option',
    this.galleryButtonText = 'Choose from photos',
    this.cameraButtonText = 'Take Photo',
    this.cancelButtonText = 'Cancel',
    this.removeButtonText = 'Remove',
  });

  ImagePickerUIConfig copyWith({
    String? title,
    String? galleryButtonText,
    String? cameraButtonText,
    String? cancelButtonText,
    String? removeButtonText,
  }) {
    return ImagePickerUIConfig(
      title: title ?? this.title,
      galleryButtonText: galleryButtonText ?? this.galleryButtonText,
      cameraButtonText: cameraButtonText ?? this.cameraButtonText,
      cancelButtonText: cancelButtonText ?? this.cancelButtonText,
      removeButtonText: removeButtonText ?? this.removeButtonText,
    );
  }

  @override
  String toString() {
    return 'ImagePickerUIConfig(title: $title, galleryButtonText: $galleryButtonText, cameraButtonText: $cameraButtonText, cancelButtonText: $cancelButtonText, removeButtonText: $removeButtonText)';
  }
}
