import 'package:flutter/foundation.dart';

/// Extension for string manipulation
extension StringExtension on String {
  String capitalize() {
    return isNotEmpty ? '${this[0].toUpperCase()}${substring(1)}' : this;
  }

  void log([String? tag]) {
    if (kDebugMode) {
      print('${tag != null ? '[$tag] ' : ''}$this');
    }
  }
}
