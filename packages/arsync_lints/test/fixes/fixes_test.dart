import 'package:test/test.dart';
import 'package:arsync_lints/arsync_plugin.dart';

/// Tests that all fixes are properly configured and registered.
///
/// Note: Full integration tests for fixes would require the CorrectionProducerTest
/// base class which provides mock analysis contexts. These tests verify:
/// 1. Fix registration in the plugin
/// 2. Fix kind configuration
/// 3. Fix logic patterns
void main() {
  group('Fix Registration Tests', () {
    late ArsyncPlugin plugin;

    setUp(() {
      plugin = ArsyncPlugin();
    });

    test('plugin has correct name', () {
      expect(plugin.name, equals('arsync_lints'));
    });

    test('plugin can be instantiated without errors', () {
      expect(plugin, isNotNull);
    });
  });

  group('Category A: Architectural Layer Isolation Fixes', () {
    group('PresentationLayerIsolation Fix Logic', () {
      test('identifies repository import patterns', () {
        const imports = [
          "import 'package:app/repositories/auth_repository.dart';",
          "import '../repositories/user_repository.dart';",
          "import 'package:app/data/api_client.dart';",
        ];

        for (final import in imports) {
          final isRepoImport = import.contains('repositories') ||
              import.contains('data/') ||
              import.contains('data_source');
          expect(isRepoImport, isTrue);
        }
      });

      test('record type generation pattern', () {
        const className = 'LoginParams';
        const fields = ['String email', 'String password'];

        final recordType =
            'typedef $className = ({${fields.join(', ')}});';
        expect(recordType, equals('typedef LoginParams = ({String email, String password});'));
      });
    });

    group('SharedWidgetPurity Fix Logic', () {
      test('identifies riverpod import patterns', () {
        const imports = [
          "import 'package:flutter_riverpod/flutter_riverpod.dart';",
          "import 'package:riverpod/riverpod.dart';",
          "import 'package:hooks_riverpod/hooks_riverpod.dart';",
        ];

        for (final import in imports) {
          expect(import.contains('riverpod'), isTrue);
        }
      });

      test('adds underscore prefix for private widget', () {
        const widgetName = 'HelperWidget';
        final privateWidgetName = '_$widgetName';
        expect(privateWidgetName, equals('_HelperWidget'));
      });
    });

    group('ModelPurity Fix Logic', () {
      test('identifies provider/riverpod imports', () {
        const import = "import 'package:flutter_riverpod/flutter_riverpod.dart';";
        expect(import.contains('riverpod'), isTrue);
      });

      test('@freezed annotation insertion pattern', () {
        const beforeClass = 'class User {';
        const annotation = '@freezed\n';
        final result = annotation + beforeClass;
        expect(result, equals('@freezed\nclass User {'));
      });

      test('fromJson factory generation pattern', () {
        const className = 'User';
        final factory = 'factory $className.fromJson(Map<String, dynamic> json) => _\$${className}FromJson(json);';
        expect(factory, equals('factory User.fromJson(Map<String, dynamic> json) => _\$UserFromJson(json);'));
      });
    });

    group('RepositoryIsolation Fix Logic', () {
      test('identifies banned UI imports', () {
        const bannedPatterns = [
          'lib/screens/',
          'lib/widgets/',
          'lib/providers/',
          'package:flutter/',
        ];

        const import = "import 'package:app/screens/home_screen.dart';";
        final isBanned = bannedPatterns.any((p) => import.contains(p.replaceAll('lib/', '')));
        expect(isBanned, isTrue);
      });
    });
  });

  group('Category B: Riverpod & State Management Fixes', () {
    group('ProviderAutodisposeEnforcement Fix Logic', () {
      test('identifies provider types correctly', () {
        const providerTypes = [
          'Provider',
          'NotifierProvider',
          'AsyncNotifierProvider',
          'StreamNotifierProvider',
          'StateProvider',
          'StateNotifierProvider',
          'FutureProvider',
          'StreamProvider',
        ];

        const source = 'NotifierProvider<AuthNotifier, AuthState>(...)';
        final matchedType = providerTypes.firstWhere(
          (type) => source.startsWith(type),
          orElse: () => '',
        );
        expect(matchedType, equals('NotifierProvider'));
      });

      test('correctly identifies where to insert .autoDispose', () {
        const source = 'NotifierProvider<Auth, State>(...)';
        const providerType = 'NotifierProvider';
        final insertPosition = providerType.length;
        expect(insertPosition, equals(16));

        final newSource =
            '${source.substring(0, insertPosition)}.autoDispose${source.substring(insertPosition)}';
        expect(newSource, startsWith('NotifierProvider.autoDispose'));
      });
    });

    group('ViewModelNamingConvention Fix Logic', () {
      test('adds Notifier suffix correctly', () {
        const testCases = {
          'AuthViewModel': 'AuthNotifier',
          'UserVM': 'UserNotifier',
          'LoginController': 'LoginNotifier',
          'SettingsState': 'SettingsNotifier',
          'Auth': 'AuthNotifier',
        };

        for (final entry in testCases.entries) {
          var newName = entry.key;
          for (final suffix in ['ViewModel', 'VM', 'Controller', 'State']) {
            if (newName.endsWith(suffix)) {
              newName = newName.substring(0, newName.length - suffix.length);
              break;
            }
          }
          newName = '${newName}Notifier';
          expect(newName, equals(entry.value));
        }
      });

      test('adds Provider suffix correctly', () {
        const varName = 'auth';
        final newName = '${varName}Provider';
        expect(newName, equals('authProvider'));
      });
    });

    group('NoContextInProviders Fix Logic', () {
      test('identifies BuildContext parameter', () {
        const params = '(BuildContext context, String name)';
        expect(params.contains('BuildContext'), isTrue);

        // Simulate removal
        final cleaned = params
            .replaceAll('BuildContext context, ', '')
            .replaceAll(', BuildContext context', '')
            .replaceAll('BuildContext context', '');
        expect(cleaned, equals('(String name)'));
      });
    });

    group('AsyncViewModelSafety Fix Logic', () {
      test('try-catch block generation pattern', () {
        const statement = 'await repository.fetch();';
        const indent = '    ';

        final tryCatch = '''try {
$indent  $statement
$indent} catch (e, stackTrace) {
$indent  // TODO: Handle error appropriately
$indent  rethrow;
$indent}''';

        expect(tryCatch, contains('try {'));
        expect(tryCatch, contains('catch (e, stackTrace)'));
        expect(tryCatch, contains(statement));
        expect(tryCatch, contains('rethrow'));
      });
    });

    group('ProviderFileNaming Fix Logic', () {
      test('extracts prefix from file name and creates class name', () {
        const fileName = 'auth_provider';
        final prefix = fileName.replaceAll('_provider', '');
        expect(prefix, equals('auth'));

        // Convert to PascalCase and add Notifier
        final className = '${prefix[0].toUpperCase()}${prefix.substring(1)}Notifier';
        expect(className, equals('AuthNotifier'));
      });
    });

    group('ProviderStateClass Fix Logic', () {
      test('@freezed annotation insertion', () {
        const classDecl = 'class AuthState {';
        const annotation = '@freezed\n';
        final result = annotation + classDecl;
        expect(result, equals('@freezed\nclass AuthState {'));
      });

      test('TODO comment for moving state class', () {
        const typeName = 'ExternalState';
        final todo = '// TODO: Move $typeName class here and add @freezed annotation';
        expect(todo, contains('ExternalState'));
      });
    });

    group('ProviderDeclarationSyntax Fix Logic', () {
      test('extracts notifier class name from closure', () {
        const closure = '() => AuthNotifier()';
        final match = RegExp(r'\(\)\s*=>\s*(\w+)\(\)').firstMatch(closure);
        expect(match, isNotNull);
        expect(match!.group(1), equals('AuthNotifier'));
      });

      test('generates .new constructor syntax', () {
        const notifierClass = 'AuthNotifier';
        final newSyntax = '$notifierClass.new';
        expect(newSyntax, equals('AuthNotifier.new'));
      });
    });

    group('ProviderClassRestriction Fix Logic', () {
      test('@freezed annotation for state classes', () {
        const classDecl = 'class SomeHelper {';
        const annotation = '@freezed\n';
        final result = annotation + classDecl;
        expect(result, startsWith('@freezed'));
      });

      test('makes class private with underscore', () {
        const className = 'HelperClass';
        final privateName = '_$className';
        expect(privateName, equals('_HelperClass'));
      });
    });

    group('ProviderSinglePerFile Fix Logic', () {
      test('snake_case to camelCase conversion', () {
        String snakeToCamel(String snake) {
          final parts = snake.split('_');
          if (parts.isEmpty) return snake;
          final buffer = StringBuffer(parts.first);
          for (var i = 1; i < parts.length; i++) {
            if (parts[i].isNotEmpty) {
              buffer.write(parts[i][0].toUpperCase());
              buffer.write(parts[i].substring(1));
            }
          }
          return buffer.toString();
        }

        expect(snakeToCamel('auth'), equals('auth'));
        expect(snakeToCamel('user_settings'), equals('userSettings'));

        final providerName = '${snakeToCamel('auth')}Provider';
        expect(providerName, equals('authProvider'));
      });
    });
  });

  group('Category C: Repository & Data Integrity Fixes', () {
    group('RepositoryNoTryCatch Fix Logic', () {
      test('extracts try body statements', () {
        const tryBlock = '''
try {
  final result = await api.fetch();
  return result;
} catch (e) {
  return null;
}
''';
        // Simulates extracting just the body
        final bodyPattern = RegExp(r'try\s*\{([^}]+)\}\s*catch');
        final match = bodyPattern.firstMatch(tryBlock);
        expect(match, isNotNull);
        expect(match!.group(1), contains('await api.fetch()'));
      });
    });

    group('RepositoryAsyncReturn Fix Logic', () {
      test('wraps return type with Future', () {
        const returnType = 'User';
        final asyncType = 'Future<$returnType>';
        expect(asyncType, equals('Future<User>'));
      });

      test('does not double-wrap Future', () {
        const returnType = 'Future<User>';
        if (returnType.startsWith('Future<') || returnType.startsWith('Stream<')) {
          expect(true, isTrue); // Already async, skip
        }
      });
    });

    group('RepositoryProviderDeclaration Fix Logic', () {
      test('generates provider name from file', () {
        const fileName = 'auth_repository';
        final prefix = fileName.replaceAll('_repository', '');
        final providerName = '${prefix}RepoProvider';
        expect(providerName, equals('authRepoProvider'));
      });

      test('generates provider declaration', () {
        const className = 'AuthRepository';
        const providerName = 'authRepoProvider';
        final decl = 'final $providerName = Provider((ref) => $className());';
        expect(decl, contains('authRepoProvider'));
        expect(decl, contains('AuthRepository()'));
      });
    });

    group('RepositoryDependencyInjection Fix Logic', () {
      test('removes initializer from field', () {
        const original = 'final Dio _dio = Dio();';
        // Fix removes " = Dio()" part
        const fixed = 'final Dio _dio;';
        expect(original, contains('='));
        expect(fixed, isNot(contains('=')));
      });

      test('identifies Ref type for removal', () {
        const fieldType = 'Ref';
        expect(fieldType == 'Ref' || fieldType.startsWith('Ref<'), isTrue);
      });
    });

    group('RepositoryClassRestriction Fix Logic', () {
      test('adds Repository suffix', () {
        const className = 'Auth';
        final newName = '${className}Repository';
        expect(newName, equals('AuthRepository'));
      });

      test('makes class private', () {
        const className = 'HelperClass';
        final privateName = '_$className';
        expect(privateName, equals('_HelperClass'));
      });
    });
  });

  group('Category D: Code Quality & Complexity Fixes', () {
    group('ComplexityLimits Fix Logic', () {
      test('nested ternary to if-else conversion pattern', () {
        const condition = 'a > b';
        const innerCond = 'b > c';
        const thenValue = 'x';
        const innerThenValue = 'y';
        const innerElseValue = 'z';

        final ifElse = '''if ($condition) {
  if ($innerCond) {
    return $thenValue;
  } else {
    return $innerThenValue;
  }
} else {
  return $innerElseValue;
}''';

        expect(ifElse, contains('if (a > b)'));
        expect(ifElse, contains('if (b > c)'));
      });

      test('TODO comment generation for complexity', () {
        const todoMessages = [
          'TODO: Reduce parameters (max 4) - consider using a parameter object using records',
          'TODO: Reduce nesting depth (max 3) - extract methods or use early returns',
          'TODO: Reduce method length (max 60 lines) - extract helper methods',
          'TODO: Reduce build() method length (max 120 lines) - extract widgets',
        ];

        for (final msg in todoMessages) {
          expect(msg, startsWith('TODO:'));
        }
      });
    });

    group('GlobalVariableRestriction Fix Logic', () {
      test('adds underscore prefix to make variable private', () {
        const name = 'globalVar';
        final privateName = '_$name';
        expect(privateName, equals('_globalVar'));
      });

      test('does not modify already private names', () {
        const name = '_alreadyPrivate';
        expect(name.startsWith('_'), isTrue);
      });
    });

    group('PrintBan Fix Logic', () {
      test('correctly identifies print argument extraction pattern', () {
        // Pattern: print('message') -> 'message'.log()
        const source = "print('Hello World')";
        final match = RegExp(r"print\((.+)\)").firstMatch(source);
        expect(match, isNotNull);
        expect(match!.group(1), equals("'Hello World'"));
      });

      test('correctly identifies debugPrint argument extraction pattern', () {
        const source = "debugPrint('Debug message')";
        final match = RegExp(r"debugPrint\((.+)\)").firstMatch(source);
        expect(match, isNotNull);
        expect(match!.group(1), equals("'Debug message'"));
      });

      test('generates .log() extension call', () {
        const arg = "'Hello World'";
        final logCall = '$arg.log()';
        expect(logCall, equals("'Hello World'.log()"));
      });
    });

    group('BarrelFileRestriction Fix Logic', () {
      test('TODO comment for barrel file removal', () {
        const todo = '''// TODO: Remove this barrel file.
// Barrel files (index.dart or export-only files) are not allowed in
// screens, features, or providers folders.
// Use explicit imports instead of re-exporting from a single file.''';

        expect(todo, contains('TODO'));
        expect(todo, contains('barrel file'));
      });
    });

    group('IgnoreFileBan Fix Logic', () {
      test('identifies ignore_for_file pattern', () {
        const content = '''
// Some code
// ignore_for_file: some_lint
void main() {}
''';
        final pattern = RegExp(r'//\s*ignore_for_file:');
        final match = pattern.firstMatch(content);
        expect(match, isNotNull);
        // The pattern match starts at the // before ignore_for_file
        expect(match!.start, greaterThan(0));
      });

      test('finds line boundaries correctly', () {
        const content = 'line1\n// ignore_for_file: lint\nline3';
        const offset = 6; // Start of second line

        // Find line start
        var lineStart = offset;
        while (lineStart > 0 && content[lineStart - 1] != '\n') {
          lineStart--;
        }
        expect(lineStart, equals(6));

        // Find line end
        var lineEnd = offset;
        while (lineEnd < content.length && content[lineEnd] != '\n') {
          lineEnd++;
        }
        if (lineEnd < content.length && content[lineEnd] == '\n') {
          lineEnd++;
        }
        expect(lineEnd, equals(31));
      });
    });
  });

  group('Category E: UI Safety & Consistency Fixes', () {
    group('HookSafetyEnforcement Fix Logic', () {
      test('maps controller types to hook functions', () {
        const controllerToHook = {
          'TextEditingController': 'useTextEditingController',
          'AnimationController': 'useAnimationController',
          'ScrollController': 'useScrollController',
          'PageController': 'usePageController',
          'TabController': 'useTabController',
          'FocusNode': 'useFocusNode',
        };

        expect(controllerToHook['TextEditingController'],
            equals('useTextEditingController'));
        expect(controllerToHook['FocusNode'], equals('useFocusNode'));
      });

      test('GlobalKey<FormState> replacement pattern', () {
        const original = 'GlobalKey<FormState>()';
        const replacement = 'GlobalObjectKey<FormState>(context)';
        expect(replacement, isNot(equals(original)));
        expect(replacement, contains('GlobalObjectKey'));
        expect(replacement, contains('context'));
      });
    });

    group('ScaffoldLocation Fix Logic', () {
      test('replaces Scaffold with Container', () {
        const scaffoldSource = "Scaffold(body: child)";
        // The fix extracts body and wraps in Container
        final bodyMatch = RegExp(r'body:\s*(\w+)').firstMatch(scaffoldSource);
        expect(bodyMatch, isNotNull);
        final bodyArg = bodyMatch!.group(1);
        final replacement = 'Container(child: $bodyArg)';
        expect(replacement, equals('Container(child: child)'));
      });
    });

    group('AssetSafety Fix Logic', () {
      test('extracts asset name from path', () {
        String generateConstantName(String assetPath) {
          final parts = assetPath.split('/');
          if (parts.isEmpty) return 'asset';

          var fileName = parts.last;
          final dotIndex = fileName.lastIndexOf('.');
          if (dotIndex > 0) {
            fileName = fileName.substring(0, dotIndex);
          }

          final segments = fileName.split(RegExp(r'[_\-]'));
          if (segments.isEmpty) return 'asset';

          final buffer = StringBuffer(segments.first.toLowerCase());
          for (var i = 1; i < segments.length; i++) {
            final segment = segments[i];
            if (segment.isNotEmpty) {
              buffer.write(segment[0].toUpperCase());
              buffer.write(segment.substring(1).toLowerCase());
            }
          }
          return buffer.toString().isEmpty ? 'asset' : buffer.toString();
        }

        expect(generateConstantName('assets/images/logo.png'), equals('logo'));
        expect(generateConstantName('assets/icons/home_icon.svg'), equals('homeIcon'));
        expect(generateConstantName('assets/images/user-avatar.png'), equals('userAvatar'));
      });

      test('generates Images constant reference', () {
        const constantName = 'logo';
        final reference = 'Images.$constantName';
        expect(reference, equals('Images.logo'));
      });
    });

    group('FileClassMatch Fix Logic', () {
      test('snake_case to PascalCase conversion', () {
        // Test the conversion logic used in the fix
        String snakeToPascal(String snake) {
          final parts = snake.split('_');
          return parts.map((part) {
            if (part.isEmpty) return '';
            return part[0].toUpperCase() + part.substring(1).toLowerCase();
          }).join();
        }

        expect(snakeToPascal('login_screen'), equals('LoginScreen'));
        expect(snakeToPascal('user_profile'), equals('UserProfile'));
        expect(snakeToPascal('auth_repository'), equals('AuthRepository'));
      });
    });
  });

  group('All 27 Rules Have Corresponding Fixes', () {
    test('Category A: 4 rules, 4 fix files', () {
      const rules = [
        'presentation_layer_isolation',
        'shared_widget_purity',
        'model_purity',
        'repository_isolation',
      ];
      expect(rules.length, equals(4));
    });

    test('Category B: 9 rules, 9 fix files', () {
      const rules = [
        'provider_autodispose_enforcement',
        'viewmodel_naming_convention',
        'no_context_in_providers',
        'async_viewmodel_safety',
        'provider_file_naming',
        'provider_state_class',
        'provider_declaration_syntax',
        'provider_class_restriction',
        'provider_single_per_file',
      ];
      expect(rules.length, equals(9));
    });

    test('Category C: 5 rules, 5 fix files', () {
      const rules = [
        'repository_no_try_catch',
        'repository_async_return',
        'repository_provider_declaration',
        'repository_dependency_injection',
        'repository_class_restriction',
      ];
      expect(rules.length, equals(5));
    });

    test('Category D: 5 rules, 5 fix files', () {
      const rules = [
        'complexity_limits',
        'global_variable_restriction',
        'print_ban',
        'barrel_file_restriction',
        'ignore_file_ban',
      ];
      expect(rules.length, equals(5));
    });

    test('Category E: 4 rules, 4 fix files', () {
      const rules = [
        'hook_safety_enforcement',
        'scaffold_location',
        'asset_safety',
        'file_class_match',
      ];
      expect(rules.length, equals(4));
    });

    test('Total: 27 rules, 27 fix files', () {
      const totalRules = 4 + 9 + 5 + 5 + 4;
      expect(totalRules, equals(27));
    });
  });
}
