import 'package:image_picker/image_picker.dart';

import '../core/image_picker_service.dart';
import '../core/interfaces.dart';

/// Optional validator for image file size
class FileSizeValidator implements ImageValidator {
  final double maxSizeMB;
  final String _errorMessage;

  FileSizeValidator({required this.maxSizeMB, String? errorMessage})
    : _errorMessage =
          errorMessage ?? 'File size exceeds the limit of $maxSizeMB MB';

  @override
  Future<bool> validate(XFile image) async {
    final sizeMB = await ArsyncImagePicker.getFileSizeMB(image);
    return sizeMB <= maxSizeMB;
  }

  @override
  String get errorMessage => _errorMessage;
}
