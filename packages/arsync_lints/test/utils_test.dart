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

    group('isGeneratedFile', () {
      test('returns true for GENERATED CODE marker', () {
        const content = '''
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_\$UserImpl _\$\$UserImplFromJson(Map<String, dynamic> json) => _\$UserImpl(
      name: json['name'] as String,
    );
''';
        expect(PathUtils.isGeneratedFile(content), true);
      });

      test('returns true for DO NOT MODIFY BY HAND marker', () {
        const content = '''
// DO NOT MODIFY BY HAND

part of 'app_user.dart';
''';
        expect(PathUtils.isGeneratedFile(content), true);
      });

      test('returns true for freezed generated file', () {
        const content = '''
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use

part of 'user.dart';

class _\$UserImpl implements User {
  const _\$UserImpl({required this.name});
  final String name;
}
''';
        expect(PathUtils.isGeneratedFile(content), true);
      });

      test('returns false for normal source file', () {
        const content = '''
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Hello')),
    );
  }
}
''';
        expect(PathUtils.isGeneratedFile(content), false);
      });

      test('returns false for file with comments but no generated marker', () {
        const content = '''
// This is a regular comment
// Another comment

void main() {
  print('Hello');
}
''';
        expect(PathUtils.isGeneratedFile(content), false);
      });

      test('returns false for empty file', () {
        expect(PathUtils.isGeneratedFile(''), false);
      });

      test('checks only first 500 characters for performance', () {
        // Create content where marker appears after 500 chars
        final padding = 'a' * 600;
        final content = '''
// Regular file
$padding
// GENERATED CODE - DO NOT MODIFY BY HAND
''';
        // Should return false because marker is beyond 500 char check
        expect(PathUtils.isGeneratedFile(content), false);
      });

      test('returns true when marker is within first 500 characters', () {
        const content = '''
// GENERATED CODE - DO NOT MODIFY BY HAND

// Some content here
void main() {}
''';
        expect(PathUtils.isGeneratedFile(content), true);
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

}
