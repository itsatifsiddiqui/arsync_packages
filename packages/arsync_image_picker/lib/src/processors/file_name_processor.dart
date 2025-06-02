import 'dart:async';

import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

import '../core/interfaces.dart';
import '../utils/extensions.dart';

/// A processor for renaming image files
class FileNameProcessor implements ImageProcessor {
  final String newFileName;

  // This is used to generate a unique filename for multiple images
  // This is useful when editing a single image from multiple images
  final int? indexParam;

  // This is used to change the filename of the image before saving it
  final Function(String, int)? nameGenerator;

  FileNameProcessor({
    required this.newFileName,
    this.indexParam,
    this.nameGenerator,
  });

  @override
  FutureOr<bool> shouldProcess(XFile image, bool isMultiple, int index) {
    // Single File
    if (indexParam == null && isMultiple == false) {
      final filename = path.basename(image.path);
      return filename != newFileName;
    }

    // Multiple Files
    if (indexParam == null && isMultiple == true) {
      final filename = '${path.basename(image.path)}_$index';
      final newFileNameIndexed = '${newFileName}_$index';
      return filename != newFileNameIndexed;
    }

    // Multiple Files with indexParam
    if (indexParam != null && isMultiple == true) {
      final newIndex = indexParam! + index;
      final filename = '${path.basename(image.path)}_$newIndex';
      final newFileNameIndexed = '${newFileName}_$newIndex';
      return filename != newFileNameIndexed;
    }

    // Editing a single image from multiple images
    final filename = '${path.basename(image.path)}_$indexParam';
    final newFileNameIndexed = '${newFileName}_$indexParam';
    return filename != newFileNameIndexed;
  }

  @override
  Future<XFile> process(XFile image, bool isMultiple, int index) async {
    final extension = path.extension(image.path);

    // Single File
    if (indexParam == null && isMultiple == false) {
      final newPath = path.join(
        path.dirname(image.path),
        '$newFileName$extension',
      );

      await image.saveTo(newPath);

      return XFile(newPath);
    }

    // Multiple Files
    if (indexParam == null && isMultiple == true) {
      final newFileNameIndexed =
          nameGenerator?.call(newFileName, index) ?? '${newFileName}_$index';

      final newPath = path.join(
        path.dirname(image.path),
        '$newFileNameIndexed$extension',
      );

      await image.saveTo(newPath);

      return XFile(newPath);
    }

    // Multiple Files with indexParam
    if (indexParam != null && isMultiple == true) {
      final newIndex = indexParam! + index;
      final newFileNameIndexed =
          nameGenerator?.call(newFileName, newIndex) ??
          '${newFileName}_$newIndex';

      final newPath = path.join(
        path.dirname(image.path),
        '$newFileNameIndexed$extension',
      );

      await image.saveTo(newPath);

      return XFile(newPath);
    }

    'Editing a single image from multiple images'.log('process');

    // Editing a single image from multiple images
    final newFileNameIndexed =
        nameGenerator?.call(newFileName, indexParam!) ??
        '${newFileName}_$indexParam';
    final newPath = path.join(
      path.dirname(image.path),
      '$newFileNameIndexed$extension',
    );

    await image.saveTo(newPath);

    return XFile(newPath);
  }
}
