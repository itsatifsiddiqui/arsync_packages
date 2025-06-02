# arsync_image_picker

A flexible, extensible image picker for Flutter with plug-and-play addons.

## Features

- 🎯 Simple API with powerful customization
- 🔧 Extensible processors and validators
- 📱 Multiple UI styles (Material Design, Cupertino)
- 🔌 Plug-and-play addon system
- 📦 Lightweight core with optional heavy features
- ✅ Built-in file size validation
- 🔄 Format conversion (JPG/PNG)
- 📝 File renaming support

## Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  arsync_image_picker: ^latest_version
```

## Quick Start

```dart
import 'package:arsync_image_picker/arsync_image_picker.dart';

// Create a picker instance
final picker = ArsyncImagePickerService();

// Add optional validators
picker.addValidator(FileSizeValidator(maxSizeMB: 5.0));

// Pick a single image
final image = await picker.pickImage(context: context);

// Pick multiple images
final images = await picker.pickImages(context: context);
```

## Basic Usage

### Single Image

```dart
final picker = ArsyncImagePickerService();

final image = await picker.pickImage(
  context: context,
  onImageSelected: () {
    // Show loading indicator
    print('Processing image...');
  },
);

if (image != null) {
  // Use your image
  print('Image path: ${image.path}');
}
```

### Multiple Images

```dart
final images = await picker.pickImages(
  context: context,
  onImagesSelected: () {
    print('Processing images...');
  },
);

if (images != null) {
  print('Selected ${images.length} images');
}
```

### Direct Gallery/Camera Access

```dart
// Pick from gallery only
final image = await picker.pickImageFromGallery(context: context);

// Take photo with camera only
final image = await picker.pickImageFromCamera(context: context);
```

## Built-in Features

### File Size Validation

```dart
picker.addValidator(FileSizeValidator(maxSizeMB: 5.0));
```

### File Renaming

```dart
picker.addProcessor(FileNameProcessor(newFileName: 'profile_pic'));
```

### Format Conversion

```dart
picker.addProcessor(FormatConverterProcessor(
  targetFormat: ImageFormatType.jpg,
));
```

## Custom UI

### Material Design (Default)

```dart
final picker = ArsyncImagePickerService(
  uiProvider: DefaultImagePickerUI(),
);
```

### Cupertino Style

```dart
final picker = ArsyncImagePickerService(
  uiProvider: CupertinoImagePickerUI(),
);
```

### Custom UI Config

```dart
final picker = ArsyncImagePickerService(
  uiConfig: ImagePickerUIConfig(
    title: 'Select Photo',
    galleryButtonText: 'Choose from Library',
    cameraButtonText: 'Take New Photo',
  ),
);
```

## Available Addons

Extend functionality with these optional addon packages:

### Image Compression

Add smart image compression to reduce file sizes:

```yaml
dependencies:
  arsync_image_picker: ^latest_version
  arsync_image_compression: ^latest_version
```

```dart
import 'package:arsync_image_compression/arsync_image_compression.dart';

picker.addProcessor(ImageCompressionProcessor(
  targetMaxSizeMB: 2.0,
  quality: 80,
));
```

### Image Cropping

Add interactive image cropping functionality:

```yaml
dependencies:
  arsync_image_picker: ^latest_version
  arsync_image_cropper: ^latest_version
```

```dart
import 'package:arsync_image_cropper/arsync_image_cropper.dart';

picker.addProcessor(ImageCroppingProcessor(
  options: CropOptions(
    aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1), // Square crop
    title: 'Crop Your Image',
  ),
));
```

## Permissions

### Android

No permissions are required.

### iOS

Add these to `ios/Runner/Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>This app needs camera access to take photos</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>This app needs photo library access to select images</string>
```

## Creating Custom Processors

```dart
class CustomProcessor implements ImageProcessor {
  @override
  Future<bool> shouldProcess(XFile image, bool isMultiple, int index) async {
    // Return true if this image should be processed
    return true;
  }

  @override
  Future<XFile> process(XFile image, bool isMultiple, int index) async {
    // Process the image and return the result
    return image;
  }
}

// Use it
picker.addProcessor(CustomProcessor());
```

## Creating Custom Validators

```dart
class CustomValidator implements ImageValidator {
  @override
  Future<bool> validate(XFile image) async {
    // Return true if image is valid
    return true;
  }

  @override
  String get errorMessage => 'Custom validation failed';
}

// Use it
picker.addValidator(CustomValidator());
```



## Author

**Atif Siddiqui**
- Email: itsatifsiddiqui@gmail.com
- GitHub: [itsatifsiddiqui](https://github.com/itsatifsiddiqui)
- LinkedIn: [Atif Siddiqui](https://www.linkedin.com/in/atif-siddiqui-213a2217b/)


## About Arsync Solutions

[Arsync Solutions](https://arsyncsolutions.com), We build Flutter apps for iOS, Android, and the web.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Contributing

Contributions are welcome! If you find a bug or want a feature, please open an issue.