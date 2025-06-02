# arsync_image_compression

Smart image compression addon for [arsync_image_picker](https://pub.dev/packages/arsync_image_picker).

## Features

- 🗜️ Smart image compression with automatic quality adjustment
- 📏 Target file size control (compress to specific MB)
- 🔄 Multi-attempt compression with quality fallback
- 🔧 Seamless integration with arsync_image_picker

## Installation

Add both packages to your `pubspec.yaml`:

```yaml
dependencies:
  arsync_image_picker: ^0.1.0
  arsync_image_compression: ^0.1.0
```

### Refer to [flutter_image_compress](https://pub.dev/packages/flutter_image_compress) package for more details about platform specific settings.

## Quick Start

```dart
import 'package:arsync_image_picker/arsync_image_picker.dart';
import 'package:arsync_image_compression/arsync_image_compression.dart';

final picker = SuperImagePickerService();

// Add compression processor
picker.addProcessor(ImageCompressionProcessor(targetMaxSizeMB: 5.0));

// Pick and compress image
final image = await picker.pickImage(context: context);
```

## Basic Usage

### Default Compression

```dart
// Compress to 2MB max with default quality
picker.addProcessor(ImageCompressionProcessor(targetMaxSizeMB: 2.0));
```

### Custom Quality

```dart
picker.addProcessor(ImageCompressionProcessor(
  targetMaxSizeMB: 1.5,
  quality: 85, // Initial quality (default is 80)
  minQuality: 20, // Minimum quality threshold (default is 10)
));
```

### Advanced Configuration

```dart
picker.addProcessor(ImageCompressionProcessor(
  targetMaxSizeMB: 3.0,
  quality: 90,
  minQuality: 30,
  maxAttempts: 5, // Max compression attempts (default is 3)
));
```
## How It Works

The compression processor uses a smart multi-attempt approach:

1. **Check if compression needed** - Only compresses if image exceeds target size
2. **Initial compression** - Starts with your specified quality setting
3. **Iterative reduction** - If still too large, reduces quality by 30% and tries again
4. **Quality threshold** - Stops when reaching minimum quality to prevent over-compression
5. **Attempt limit** - Maximum attempts to prevent infinite loops


## Dependencies

This package depends on:
- [arsync_image_picker](https://pub.dev/packages/arsync_image_picker) - Core image picker functionality
- [flutter_image_compress](https://pub.dev/packages/flutter_image_compress) - Native compression engine

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