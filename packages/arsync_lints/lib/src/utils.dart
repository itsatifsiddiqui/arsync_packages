import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/source/line_info.dart';
import 'package:path/path.dart' as p;

/// Cache for LineInfo objects to avoid recreating them.
/// All rules analyzing the same file will share the same LineInfo.
class LineInfoCache {
  static final Map<int, LineInfo> _cache = {};

  /// Get or create cached LineInfo for the given content.
  static LineInfo get(String content) {
    return _cache.putIfAbsent(
      content.hashCode,
      () => LineInfo.fromContent(content),
    );
  }

  /// Clear the cache.
  static void clear() {
    _cache.clear();
  }
}

/// Utility class for path checking and common operations.
/// Optimized with caching for repeated calls on the same path.
class PathUtils {
  /// Cache for normalized paths
  static final Map<String, String> _normalizedPaths = {};

  /// Cache for snake_to_pascal conversions
  static final Map<String, String> _snakeToPascalCache = {};

  /// Pre-compiled regex for pascalToSnake
  static final RegExp _pascalToSnakeRegex = RegExp(r'([A-Z])');

  /// Normalizes a file path to use forward slashes (cross-platform support).
  /// Results are cached for efficiency.
  static String normalizePath(String path) {
    return _normalizedPaths.putIfAbsent(
      path,
      () => path.contains(r'\') ? path.replaceAll(r'\', '/') : path,
    );
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

  /// Converts snake_case to PascalCase. Results are cached.
  static String snakeToPascal(String snakeCase) {
    return _snakeToPascalCache.putIfAbsent(snakeCase, () {
      final parts = snakeCase.split('_');
      final buffer = StringBuffer();
      for (final word in parts) {
        if (word.isNotEmpty) {
          buffer.write(word[0].toUpperCase());
          if (word.length > 1) {
            buffer.write(word.substring(1).toLowerCase());
          }
        }
      }
      return buffer.toString();
    });
  }

  /// Converts PascalCase to snake_case.
  static String pascalToSnake(String pascalCase) {
    return pascalCase
        .replaceAllMapped(
          _pascalToSnakeRegex,
          (match) => '_${match.group(0)!.toLowerCase()}',
        )
        .replaceFirst('_', '');
  }

  /// Checks if the file is in screens directory.
  static bool isInScreens(String filePath) =>
      isInDirectory(filePath, 'screens');

  /// Checks if the file is in widgets directory.
  static bool isInWidgets(String filePath) =>
      isInDirectory(filePath, 'widgets');

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

  /// Clear all caches.
  static void clearCache() {
    _normalizedPaths.clear();
    _snakeToPascalCache.clear();
  }
}

/// Utility class for import checking.
/// Optimized with cached RegExp patterns for wildcard matching.
class ImportUtils {
  /// Cache for compiled wildcard regex patterns
  static final Map<String, RegExp> _wildcardPatternCache = {};

  /// Checks if an import matches a banned pattern.
  static bool matchesBannedImport(
    String importUri,
    List<String> bannedPatterns,
  ) {
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
    // Handle wildcard patterns (cached regex)
    if (pattern.contains('*')) {
      final regex = _wildcardPatternCache.putIfAbsent(pattern, () {
        final regexPattern = pattern
            .replaceAll('*', '.*')
            .replaceAll('/', r'\/')
            .replaceAll('.', r'\.');
        return RegExp('^$regexPattern');
      });
      return regex.hasMatch(importUri);
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

  /// Clear the cache.
  static void clearCache() {
    _wildcardPatternCache.clear();
  }
}

/// Pre-computed index of all ignore comments in a file.
/// Parses the file once and stores line -> lint names mapping for fast lookups.
class FileIgnoreIndex {
  /// Cache: contentHash -> FileIgnoreIndex
  static final Map<int, FileIgnoreIndex> _cache = {};

  /// Map of lineNumber -> Set of lint names ignored on that line
  final Map<int, Set<String>> _lineIgnores;

  /// Set of lint names ignored for the entire file
  final Set<String> _fileIgnores;

  FileIgnoreIndex._({
    required Map<int, Set<String>> lineIgnores,
    required Set<String> fileIgnores,
  }) : _lineIgnores = lineIgnores,
       _fileIgnores = fileIgnores;

  /// Get or create cached FileIgnoreIndex for a file.
  static FileIgnoreIndex forContent(String content) {
    final contentHash = content.hashCode;
    return _cache.putIfAbsent(contentHash, () => _parseFile(content));
  }

  /// Parse all ignore comments in a file and build the index.
  static FileIgnoreIndex _parseFile(String content) {
    final lineIgnores = <int, Set<String>>{};
    final fileIgnores = <String>{};

    // Single regex to match both ignore and ignore_for_file comments
    // Captures: group(1) = "for_file" or null, group(2) = lint names
    final ignorePattern = RegExp(
      r'//\s*ignore(_for_file)?\s*:\s*([^\n]+)',
      caseSensitive: false,
    );

    final lineInfo = LineInfoCache.get(content);
    final matches = ignorePattern.allMatches(content);

    for (final match in matches) {
      final isForFile = match.group(1) != null;
      final lintNamesStr = match.group(2)!;

      // Parse comma-separated lint names, handling whitespace
      final lintNames = lintNamesStr
          .split(',')
          .map((s) => s.trim().toLowerCase())
          .where((s) => s.isNotEmpty && !s.startsWith('type='))
          .toSet();

      if (isForFile) {
        fileIgnores.addAll(lintNames);
      } else {
        // Get line number for this ignore comment
        final lineNumber = lineInfo.getLocation(match.start).lineNumber;
        lineIgnores.putIfAbsent(lineNumber, () => {}).addAll(lintNames);
      }
    }

    return FileIgnoreIndex._(
      lineIgnores: lineIgnores,
      fileIgnores: fileIgnores,
    );
  }

  /// Check if a lint is ignored for the entire file.
  bool isIgnoredForFile(String lintName) {
    return _fileIgnores.contains(lintName.toLowerCase());
  }

  /// Check if a lint is ignored at a specific line (checks line and line before).
  bool isIgnoredAtLine(int lineNumber, String lintName) {
    final lintLower = lintName.toLowerCase();
    // Check current line and line before
    final currentLineIgnores = _lineIgnores[lineNumber];
    if (currentLineIgnores != null && currentLineIgnores.contains(lintLower)) {
      return true;
    }
    // Check previous line (common pattern: ignore comment on line before)
    final prevLineIgnores = _lineIgnores[lineNumber - 1];
    if (prevLineIgnores != null && prevLineIgnores.contains(lintLower)) {
      return true;
    }
    return false;
  }

  /// Clear the cache.
  static void clearCache() {
    _cache.clear();
  }
}

/// Helper class for checking ignore comments for a specific file and lint.
/// Use the static [forRule] factory to get a cached instance.
///
/// TODO: When https://github.com/dart-lang/sdk/issues/62173 is fixed,
/// migrate to native analyzer ignore handling and remove this class.
class IgnoreChecker {
  /// Cache: contentHash -> lintName -> IgnoreChecker
  static final Map<int, Map<String, IgnoreChecker>> _cache = {};

  final LineInfo _lineInfo;
  final String _lintName;
  final FileIgnoreIndex _index;

  /// Whether the entire file should be ignored for this lint.
  final bool ignoreForFile;

  IgnoreChecker._({required String content, required String lintName})
    : _lintName = lintName,
      _lineInfo = LineInfoCache.get(content),
      _index = FileIgnoreIndex.forContent(content),
      ignoreForFile = FileIgnoreIndex.forContent(
        content,
      ).isIgnoredForFile(lintName);

  /// Get a cached IgnoreChecker for a rule.
  /// This is the preferred way to create an IgnoreChecker - it caches
  /// instances by file content and lint name for maximum performance.
  ///
  /// Usage in registerNodeProcessors:
  /// ```dart
  /// final checker = IgnoreChecker.forRule(context, name);
  /// if (checker.ignoreForFile) return;
  /// ```
  static IgnoreChecker forRule(String content, String lintName) {
    final contentHash = content.hashCode;
    final fileCache = _cache.putIfAbsent(contentHash, () => {});
    return fileCache.putIfAbsent(
      lintName,
      () => IgnoreChecker._(content: content, lintName: lintName),
    );
  }

  /// Check if a node should be ignored.
  bool shouldIgnore(AstNode node) {
    if (ignoreForFile) return true;
    final lineNumber = _lineInfo.getLocation(node.offset).lineNumber;
    return _index.isIgnoredAtLine(lineNumber, _lintName);
  }

  /// Check if an offset should be ignored.
  bool shouldIgnoreOffset(int offset) {
    if (ignoreForFile) return true;
    final lineNumber = _lineInfo.getLocation(offset).lineNumber;
    return _index.isIgnoredAtLine(lineNumber, _lintName);
  }

  /// Clear the cache. Called automatically when files change.
  static void clearCache() {
    _cache.clear();
    FileIgnoreIndex.clearCache();
  }
}

/// Utility class for checking ignore comments.
/// Uses FileIgnoreIndex for optimized pre-computed lookups.
class IgnoreUtils {
  /// Check if the file has `// ignore_for_file: lint_name`
  /// Uses FileIgnoreIndex for O(1) lookup after initial parse.
  static bool hasIgnoreForFile(String content, String lintName) {
    final index = FileIgnoreIndex.forContent(content);
    return index.isIgnoredForFile(lintName);
  }

  /// Checks if a node should be ignored for a specific lint rule.
  ///
  /// Checks both:
  /// - `// ignore: lint_name` on the line before the node
  /// - `// ignore_for_file: lint_name` anywhere in the file
  static bool shouldIgnore({
    required AstNode node,
    required String lintName,
    required String content,
    required LineInfo lineInfo,
    required CompilationUnit unit,
  }) {
    return shouldIgnoreAtOffset(
      offset: node.offset,
      lintName: lintName,
      content: content,
      lineInfo: lineInfo,
    );
  }

  /// Checks if a position (by offset) should be ignored for a specific lint rule.
  ///
  /// Checks both:
  /// - `// ignore: lint_name` on the line before the offset
  /// - `// ignore_for_file: lint_name` anywhere in the file
  static bool shouldIgnoreAtOffset({
    required int offset,
    required String lintName,
    required String content,
    required LineInfo lineInfo,
  }) {
    final index = FileIgnoreIndex.forContent(content);

    // Check for ignore_for_file
    if (index.isIgnoredForFile(lintName)) {
      return true;
    }

    // Check for ignore on the preceding line or same line
    final lineNumber = lineInfo.getLocation(offset).lineNumber;
    return index.isIgnoredAtLine(lineNumber, lintName);
  }

  /// Clear all caches. Call between analysis sessions if needed.
  static void clearCache() {
    FileIgnoreIndex.clearCache();
  }
}

/// Utility class for type checking in Flutter widgets.
class TypeUtils {
  /// Whether the given [type] is a ListView widget.
  static bool isListViewWidget(String? typeName) => typeName == 'ListView';

  /// Whether the given [type] is a Column widget.
  static bool isColumnWidget(String? typeName) => typeName == 'Column';

  /// Whether the given [type] is a Row widget.
  static bool isRowWidget(String? typeName) => typeName == 'Row';

  /// Whether the given file is a test file.
  static bool isTestFile(String filePath) {
    final normalized = PathUtils.normalizePath(filePath);
    final isInTestDir = normalized.contains('/test/');
    final endsWithTest = normalized.endsWith('_test.dart');
    final isInLintsDir = normalized.contains('/lints/');
    final isInLibDir = normalized.contains('/lib/');
    final endsWithTestDart = normalized.endsWith('/test.dart');

    // for lint rule test files - don't treat as test
    if (isInTestDir && isInLintsDir && endsWithTest) {
      return false;
    }

    // for reflectiveTest (/home/test/lib/test.dart) - don't treat as test
    if (isInLibDir && endsWithTestDart) {
      return false;
    }

    return isInTestDir || endsWithTest;
  }
}
