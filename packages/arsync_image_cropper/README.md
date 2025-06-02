# arsync_image_cropper

Interactive image cropping addon for [arsync_image_picker](https://pub.dev/packages/arsync_image_picker).

## Features

- 🖼️ Image Copping with Multiple aspect ratio presets
- 🔧 Seamless integration with arsync_image_picker


## Installation

Add both packages to your `pubspec.yaml`:

```yaml
dependencies:
  arsync_image_picker: ^0.1.0
  arsync_image_cropper: ^0.1.0
```


### Refer to [image_cropper](https://pub.dev/packages/image_cropper) package for more details about platform specific settings.

## Quick Start

```dart
import 'package:arsync_image_picker/arsync_image_picker.dart';
import 'package:arsync_image_cropper/arsync_image_cropper.dart';

final picker = ArsyncImagePicker();

// Add cropping processor
picker.addProcessor(ImageCroppingProcessor());

// Pick and crop image
final image = await picker.pickImage(context: context);
```

## Basic Usage

### Default Cropping

```dart
// Basic cropping with default settings
picker.addProcessor(ImageCroppingProcessor());
```

### Square Crop

```dart
picker.addProcessor(ImageCroppingProcessor(
  options: CropOptions(
    aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
    lockAspectRatio: true,
  ),
));
```

### Custom Quality

```dart
picker.addProcessor(ImageCroppingProcessor(
  quality: 90, // Higher quality (default is 50)
  options: CropOptions(
    title: 'Crop Your Photo',
  ),
));
```

## Crop Options

### Aspect Ratios

```dart
// Predefined aspect ratios
picker.addProcessor(ImageCroppingProcessor(
  options: CropOptions(
    aspectRatioPresets: [
      CropAspectRatioPreset.square,
      CropAspectRatioPreset.ratio16x9,
      CropAspectRatioPreset.ratio4x3,
      CropAspectRatioPreset.ratio3x2,
      CropAspectRatioPreset.original,
    ],
  ),
));

// Custom aspect ratio
picker.addProcessor(ImageCroppingProcessor(
  options: CropOptions(
    aspectRatio: CropAspectRatio(ratioX: 16, ratioY: 9),
    lockAspectRatio: true,
  ),
));
```

### UI Customization

```dart
picker.addProcessor(ImageCroppingProcessor(
  options: CropOptions(
    title: 'Crop Your Image',
    lockAspectRatio: false,
    aspectRatioPresets: [
      CropAspectRatioPreset.original,
      CropAspectRatioPreset.square,
    ],
  ),
));
```

## Dependencies

This package depends on:
- [arsync_image_picker](https://pub.dev/packages/arsync_image_picker) - Core image picker functionality
- [image_cropper](https://pub.dev/packages/image_cropper) - Native cropping interface

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