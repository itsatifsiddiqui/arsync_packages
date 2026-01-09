import 'package:path/path.dart' as p;

/// Utility class for path checking and common operations.
class PathUtils {
  /// Normalizes a file path to use forward slashes (cross-platform support).
  static String normalizePath(String path) {
    return path.replaceAll(r'\', '/');
  }

  /// Checks if the file is inside a specific directory path.
  static bool isInDirectory(String filePath, String directory) {
    final normalized = normalizePath(filePath);
    // Handle both 'lib/screens/' and '/lib/screens/' patterns
    final pattern1 = '/lib/$directory/';
    final pattern2 = 'lib/$directory/';
    return normalized.contains(pattern1) || normalized.startsWith(pattern2);
  }

  /// Checks if the file is in the lib directory.
  static bool isInLib(String filePath) {
    final normalized = normalizePath(filePath);
    return normalized.contains('/lib/') || normalized.startsWith('lib/');
  }

  /// Gets the file name without extension from a path.
  static String getFileName(String filePath) {
    final normalized = normalizePath(filePath);
    return p.basenameWithoutExtension(normalized);
  }

  /// Gets the file name with extension from a path.
  static String getFileNameWithExtension(String filePath) {
    final normalized = normalizePath(filePath);
    return p.basename(normalized);
  }

  /// Converts snake_case to PascalCase.
  static String snakeToPascal(String snakeCase) {
    return snakeCase
        .split('_')
        .map((word) => word.isEmpty
            ? ''
            : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}')
        .join();
  }

  /// Converts PascalCase to snake_case.
  static String pascalToSnake(String pascalCase) {
    return pascalCase
        .replaceAllMapped(
            RegExp(r'([A-Z])'), (match) => '_${match.group(0)!.toLowerCase()}')
        .replaceFirst('_', '');
  }

  /// Checks if the file is in screens directory.
  static bool isInScreens(String filePath) => isInDirectory(filePath, 'screens');

  /// Checks if the file is in widgets directory.
  static bool isInWidgets(String filePath) => isInDirectory(filePath, 'widgets');

  /// Checks if the file is in models directory.
  static bool isInModels(String filePath) => isInDirectory(filePath, 'models');

  /// Checks if the file is in repositories directory.
  static bool isInRepositories(String filePath) =>
      isInDirectory(filePath, 'repositories');

  /// Checks if the file is in providers directory.
  static bool isInProviders(String filePath) =>
      isInDirectory(filePath, 'providers');

  /// Checks if the file is in core directory.
  static bool isInCore(String filePath) => isInDirectory(filePath, 'core');

  /// Checks if the file is in features directory.
  static bool isInFeatures(String filePath) =>
      isInDirectory(filePath, 'features');

  /// Checks if the file is in utils directory.
  static bool isInUtils(String filePath) => isInDirectory(filePath, 'utils');

  /// Checks if the file is the constants file.
  static bool isConstantsFile(String filePath) {
    final normalized = normalizePath(filePath);
    return normalized.endsWith('/constants.dart') ||
        normalized.endsWith('/utils/constants.dart');
  }
}

/// Utility class for import checking.
class ImportUtils {
  /// Checks if an import matches a banned pattern.
  static bool matchesBannedImport(String importUri, List<String> bannedPatterns) {
    for (final pattern in bannedPatterns) {
      if (_matchesPattern(importUri, pattern)) {
        return true;
      }
    }
    return false;
  }

  /// Pattern matching for imports.
  /// Supports:
  /// - Exact match: 'package:dio/dio.dart'
  /// - Wildcard: 'package:*/repositories/*'
  /// - Simple prefix: 'package:cloud_firestore'
  /// - Contains match: 'repositories/' matches any import containing this path
  static bool _matchesPattern(String importUri, String pattern) {
    // Handle wildcard patterns
    if (pattern.contains('*')) {
      final regexPattern = pattern
          .replaceAll('*', '.*')
          .replaceAll('/', r'\/')
          .replaceAll('.', r'\.');
      return RegExp('^$regexPattern').hasMatch(importUri);
    }

    // Handle path segment patterns (e.g., 'repositories/' matches any import with this path)
    // This is a contains match for directory patterns
    if (pattern.endsWith('/') && !pattern.startsWith('package:')) {
      return importUri.contains(pattern);
    }

    // Handle prefix matches (e.g., 'package:cloud_firestore' matches 'package:cloud_firestore/...')
    if (pattern.endsWith('/*')) {
      final prefix = pattern.substring(0, pattern.length - 2);
      return importUri.startsWith(prefix);
    }

    // Exact or prefix match
    return importUri.startsWith(pattern) || importUri == pattern;
  }
}
