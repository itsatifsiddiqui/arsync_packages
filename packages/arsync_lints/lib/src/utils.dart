import 'package:path/path.dart' as p;
import 'package:recase/recase.dart';

/// Path matching and case-conversion helpers used by rules and fixes.
class PathUtils {
  /// Normalizes a file path to forward slashes (cross-platform).
  static String normalizePath(String path) =>
      path.contains(r'\') ? path.replaceAll(r'\', '/') : path;

  /// Whether [filePath] sits under `lib/<directory>/` (handles leading slash).
  static bool isInDirectory(String filePath, String directory) {
    final normalized = normalizePath(filePath);
    return normalized.contains('/lib/$directory/') ||
        normalized.startsWith('lib/$directory/');
  }

  /// Whether [filePath] sits under `lib/`.
  static bool isInLib(String filePath) {
    final n = normalizePath(filePath);
    return n.contains('/lib/') || n.startsWith('lib/');
  }

  /// File name without extension.
  static String getFileName(String filePath) =>
      p.basenameWithoutExtension(normalizePath(filePath));

  /// File name with extension.
  static String getFileNameWithExtension(String filePath) =>
      p.basename(normalizePath(filePath));

  static String snakeToPascal(String snakeCase) => snakeCase.pascalCase;
  static String snakeToCamel(String snakeCase) => snakeCase.camelCase;
  static String pascalToSnake(String pascalCase) => pascalCase.snakeCase;

  static bool isInScreens(String path) => isInDirectory(path, 'screens');
  static bool isInWidgets(String path) => isInDirectory(path, 'widgets');
  static bool isInModels(String path) => isInDirectory(path, 'models');
  static bool isInRepositories(String path) =>
      isInDirectory(path, 'repositories');
  static bool isInProviders(String path) => isInDirectory(path, 'providers');
  static bool isInCore(String path) => isInDirectory(path, 'core');
  static bool isInFeatures(String path) => isInDirectory(path, 'features');
  static bool isInUtils(String path) => isInDirectory(path, 'utils');

  static bool isConstantsFile(String filePath) {
    final n = normalizePath(filePath);
    return n.endsWith('/constants.dart') ||
        n.endsWith('/utils/constants.dart');
  }

  /// Theme/palette files are exempt from `avoid_hardcoded_color`.
  static bool isThemeOrColorFile(String filePath) {
    final n = getFileName(filePath).toLowerCase();
    return n.contains('theme') || n.contains('color') || n.contains('palette');
  }

  /// Scans the first 500 chars for the standard build_runner generated
  /// markers. Kept as a utility, but **not called from the lint hot path** —
  /// exclude generated files via `analyzer.exclude` in `analysis_options.yaml`
  /// instead.
  static bool isGeneratedFile(String content) {
    final end = content.length > 500 ? 500 : content.length;
    final header = content.substring(0, end);
    return header.contains('GENERATED CODE') ||
        header.contains('DO NOT MODIFY BY HAND');
  }
}

/// Import pattern matching. Supports exact, prefix, wildcard
/// (`package:*/foo/*`), and contains-style (`repositories/`) patterns.
class ImportUtils {
  static bool matchesBannedImport(String importUri, List<String> patterns) =>
      patterns.any((p) => _matchesPattern(importUri, p));

  static bool _matchesPattern(String importUri, String pattern) {
    if (pattern.contains('*')) {
      final re = pattern
          .replaceAll('*', '.*')
          .replaceAll('/', r'\/')
          .replaceAll('.', r'\.');
      return RegExp('^$re').hasMatch(importUri);
    }
    if (pattern.endsWith('/') && !pattern.startsWith('package:')) {
      return importUri.contains(pattern);
    }
    if (pattern.endsWith('/*')) {
      return importUri.startsWith(pattern.substring(0, pattern.length - 2));
    }
    return importUri.startsWith(pattern) || importUri == pattern;
  }
}

