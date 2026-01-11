import 'package:test/test.dart';
import 'package:arsync_lints/src/utils.dart';

void main() {
  group('PathUtils', () {
    group('normalizePath', () {
      test('converts backslashes to forward slashes', () {
        expect(
          PathUtils.normalizePath(r'lib\screens\home.dart'),
          'lib/screens/home.dart',
        );
      });

      test('leaves forward slashes unchanged', () {
        expect(
          PathUtils.normalizePath('lib/screens/home.dart'),
          'lib/screens/home.dart',
        );
      });
    });

    group('isInDirectory', () {
      test('returns true for file in specified directory', () {
        expect(
          PathUtils.isInDirectory('/project/lib/screens/home.dart', 'screens'),
          true,
        );
      });

      test('returns true for nested file in directory', () {
        expect(
          PathUtils.isInDirectory(
            '/project/lib/screens/home/home_screen.dart',
            'screens',
          ),
          true,
        );
      });

      test('returns false for file not in directory', () {
        expect(
          PathUtils.isInDirectory(
            '/project/lib/widgets/button.dart',
            'screens',
          ),
          false,
        );
      });
    });

    group('isInScreens', () {
      test('returns true for screens directory', () {
        expect(PathUtils.isInScreens('/project/lib/screens/home.dart'), true);
      });

      test('returns false for widgets directory', () {
        expect(
          PathUtils.isInScreens('/project/lib/widgets/button.dart'),
          false,
        );
      });
    });

    group('isInWidgets', () {
      test('returns true for widgets directory', () {
        expect(PathUtils.isInWidgets('/project/lib/widgets/button.dart'), true);
      });

      test('returns false for screens directory', () {
        expect(PathUtils.isInWidgets('/project/lib/screens/home.dart'), false);
      });
    });

    group('isInModels', () {
      test('returns true for models directory', () {
        expect(PathUtils.isInModels('/project/lib/models/user.dart'), true);
      });
    });

    group('isInRepositories', () {
      test('returns true for repositories directory', () {
        expect(
          PathUtils.isInRepositories('/project/lib/repositories/auth.dart'),
          true,
        );
      });
    });

    group('isInProviders', () {
      test('returns true for providers directory', () {
        expect(
          PathUtils.isInProviders('/project/lib/providers/auth.dart'),
          true,
        );
      });
    });

    group('isInLib', () {
      test('returns true for lib files', () {
        expect(PathUtils.isInLib('/project/lib/main.dart'), true);
      });

      test('returns false for test files', () {
        expect(PathUtils.isInLib('/project/test/widget_test.dart'), false);
      });
    });

    group('getFileName', () {
      test('extracts file name without extension', () {
        expect(
          PathUtils.getFileName('/project/lib/home_screen.dart'),
          'home_screen',
        );
      });

      test('handles nested paths', () {
        expect(
          PathUtils.getFileName('/project/lib/screens/home/home_screen.dart'),
          'home_screen',
        );
      });
    });

    group('snakeToPascal', () {
      test('converts snake_case to PascalCase', () {
        expect(PathUtils.snakeToPascal('home_screen'), 'HomeScreen');
      });

      test('handles single word', () {
        expect(PathUtils.snakeToPascal('home'), 'Home');
      });

      test('handles multiple words', () {
        expect(
          PathUtils.snakeToPascal('my_home_screen_widget'),
          'MyHomeScreenWidget',
        );
      });
    });

    group('pascalToSnake', () {
      test('converts PascalCase to snake_case', () {
        expect(PathUtils.pascalToSnake('HomeScreen'), 'home_screen');
      });

      test('handles single word', () {
        expect(PathUtils.pascalToSnake('Home'), 'home');
      });
    });

    group('isConstantsFile', () {
      test('returns true for constants.dart', () {
        expect(PathUtils.isConstantsFile('/project/lib/constants.dart'), true);
      });

      test('returns true for utils/constants.dart', () {
        expect(
          PathUtils.isConstantsFile('/project/lib/utils/constants.dart'),
          true,
        );
      });

      test('returns false for other files', () {
        expect(
          PathUtils.isConstantsFile('/project/lib/utils/helpers.dart'),
          false,
        );
      });
    });
  });

  group('ImportUtils', () {
    group('matchesBannedImport', () {
      test('matches exact pattern', () {
        expect(
          ImportUtils.matchesBannedImport('package:dio', ['package:dio']),
          true,
        );
      });

      test('matches prefix pattern', () {
        expect(
          ImportUtils.matchesBannedImport('package:dio/dio.dart', [
            'package:dio',
          ]),
          true,
        );
      });

      test('matches contains pattern', () {
        expect(
          ImportUtils.matchesBannedImport(
            'package:my_app/repositories/auth.dart',
            ['repositories/'],
          ),
          true,
        );
      });

      test('does not match unrelated pattern', () {
        expect(
          ImportUtils.matchesBannedImport('package:flutter/material.dart', [
            'package:dio',
          ]),
          false,
        );
      });
    });
  });

  group('IgnoreUtils', () {
    setUp(() {
      IgnoreUtils.clearCache();
      IgnoreChecker.clearCache();
    });

    group('hasIgnoreForFile', () {
      test('returns true when ignore_for_file comment exists', () {
        const content = '''
// ignore_for_file: my_lint
void main() {}
''';
        expect(IgnoreUtils.hasIgnoreForFile(content, 'my_lint'), true);
      });

      test('returns true for ignore_for_file with multiple lints', () {
        const content = '''
// ignore_for_file: other_lint, my_lint, another_lint
void main() {}
''';
        expect(IgnoreUtils.hasIgnoreForFile(content, 'my_lint'), true);
      });

      test('returns false when no ignore_for_file comment', () {
        const content = '''
void main() {}
''';
        expect(IgnoreUtils.hasIgnoreForFile(content, 'my_lint'), false);
      });

      test('returns false for different lint name', () {
        const content = '''
// ignore_for_file: other_lint
void main() {}
''';
        expect(IgnoreUtils.hasIgnoreForFile(content, 'my_lint'), false);
      });

      test('caches results for performance', () {
        const content = '''
// ignore_for_file: my_lint
void main() {}
''';
        // First call
        expect(IgnoreUtils.hasIgnoreForFile(content, 'my_lint'), true);
        // Second call should use cache
        expect(IgnoreUtils.hasIgnoreForFile(content, 'my_lint'), true);
      });
    });
  });

  group('IgnoreChecker', () {
    setUp(() {
      IgnoreUtils.clearCache();
      IgnoreChecker.clearCache();
    });

    group('forRule factory', () {
      test('returns cached instance for same content and lint', () {
        const content = 'void main() {}';
        final checker1 = IgnoreChecker.forRule(content, 'my_lint');
        final checker2 = IgnoreChecker.forRule(content, 'my_lint');
        expect(identical(checker1, checker2), true);
      });

      test('returns different instance for different lint', () {
        const content = 'void main() {}';
        final checker1 = IgnoreChecker.forRule(content, 'my_lint');
        final checker2 = IgnoreChecker.forRule(content, 'other_lint');
        expect(identical(checker1, checker2), false);
      });
    });

    group('ignoreForFile', () {
      test('is true when ignore_for_file exists', () {
        const content = '''
// ignore_for_file: my_lint
void main() {}
''';
        final checker = IgnoreChecker.forRule(content, 'my_lint');
        expect(checker.ignoreForFile, true);
      });

      test('is false when no ignore_for_file', () {
        const content = 'void main() {}';
        final checker = IgnoreChecker.forRule(content, 'my_lint');
        expect(checker.ignoreForFile, false);
      });
    });

    group('shouldIgnoreOffset', () {
      test('returns true when ignore_for_file exists', () {
        const content = '''
// ignore_for_file: my_lint
void main() {}
''';
        final checker = IgnoreChecker.forRule(content, 'my_lint');
        expect(checker.shouldIgnoreOffset(28), true); // offset of main
      });

      test('returns true when ignore comment on preceding line', () {
        const content = '''
// ignore: my_lint
void main() {}
''';
        final checker = IgnoreChecker.forRule(content, 'my_lint');
        expect(checker.shouldIgnoreOffset(19), true); // offset of void
      });

      test('returns false when no ignore comment', () {
        const content = '''
void main() {}
''';
        final checker = IgnoreChecker.forRule(content, 'my_lint');
        expect(checker.shouldIgnoreOffset(0), false);
      });

      test('returns false for ignore on wrong line', () {
        const content = '''
void first() {}
// ignore: my_lint
void second() {}
void third() {}
''';
        final checker = IgnoreChecker.forRule(content, 'my_lint');
        // first() should not be ignored (ignore is below it)
        expect(checker.shouldIgnoreOffset(0), false);
        // second() should be ignored (ignore is on preceding line)
        expect(checker.shouldIgnoreOffset(37), true);
        // third() should not be ignored (ignore is too far above)
        expect(checker.shouldIgnoreOffset(55), false);
      });

      test('matches lint name in ignore with multiple lints', () {
        const content = '''
// ignore: other, my_lint, another
void main() {}
''';
        final checker = IgnoreChecker.forRule(content, 'my_lint');
        expect(checker.shouldIgnoreOffset(35), true);
      });

      test('handles same-line ignore comment', () {
        const content = '''
void main() {} // ignore: my_lint
''';
        final checker = IgnoreChecker.forRule(content, 'my_lint');
        expect(checker.shouldIgnoreOffset(0), true);
      });
    });
  });
}
