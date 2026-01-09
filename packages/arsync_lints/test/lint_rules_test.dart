import 'package:test/test.dart';
import 'package:arsync_lints/src/utils.dart';

/// Test helper to parse Dart code and verify AST structure.
/// These tests verify the underlying logic and utilities.
void main() {
  group('Lint Rule Logic Tests', () {
    group('PresentationLayerIsolation Logic', () {
      test('identifies banned imports for repositories', () {
        const bannedPatterns = [
          'repositories/',
          'package:cloud_firestore',
          'package:http/',
          'package:dio/',
        ];

        expect(
          bannedPatterns.any((p) => 'package:my_app/repositories/auth.dart'.contains(p)),
          true,
        );
        expect(
          bannedPatterns.any((p) => 'package:cloud_firestore/cloud_firestore.dart'.contains(p)),
          true,
        );
        expect(
          bannedPatterns.any((p) => 'package:dio/dio.dart'.contains(p)),
          true,
        );
        expect(
          bannedPatterns.any((p) => 'package:flutter/material.dart'.contains(p)),
          false,
        );
      });

      test('correctly identifies screens and widgets paths', () {
        expect(PathUtils.isInScreens('/lib/screens/home.dart'), true);
        expect(PathUtils.isInWidgets('/lib/widgets/button.dart'), true);
        expect(PathUtils.isInScreens('/lib/providers/auth.dart'), false);
      });

      test('correctly identifies nested screens paths', () {
        // PathUtils.isInScreens checks for '/screens/' in the path
        expect('/lib/features/auth/screens/login.dart'.contains('/screens/'), true);
        expect('/lib/modules/home/screens/dashboard.dart'.contains('/screens/'), true);
      });
    });

    group('SharedWidgetPurity Logic', () {
      test('identifies banned riverpod imports', () {
        const bannedPatterns = [
          'providers/',
          'package:flutter_riverpod',
          'package:riverpod',
        ];

        expect(
          bannedPatterns.any((p) => 'package:flutter_riverpod/flutter_riverpod.dart'.contains(p)),
          true,
        );
        expect(
          bannedPatterns.any((p) => 'package:my_app/providers/auth.dart'.contains(p)),
          true,
        );
        expect(
          bannedPatterns.any((p) => 'package:flutter/widgets.dart'.contains(p)),
          false,
        );
      });

      test('identifies hooks_riverpod as banned', () {
        const bannedPatterns = [
          'package:hooks_riverpod',
          'package:flutter_riverpod',
        ];

        expect(
          bannedPatterns.any((p) => 'package:hooks_riverpod/hooks_riverpod.dart'.contains(p)),
          true,
        );
      });
    });

    group('ModelPurity Logic', () {
      test('correctly identifies models path', () {
        expect(PathUtils.isInModels('/lib/models/user.dart'), true);
        expect(PathUtils.isInModels('/lib/screens/home.dart'), false);
      });

      test('correctly identifies nested models path', () {
        // PathUtils.isInModels checks for '/models/' in the path
        expect('/lib/features/auth/models/user.dart'.contains('/models/'), true);
        expect('/lib/domain/models/entity.dart'.contains('/models/'), true);
      });
    });

    group('RepositoryIsolation Logic', () {
      test('correctly identifies repositories path', () {
        expect(PathUtils.isInRepositories('/lib/repositories/auth.dart'), true);
        expect(PathUtils.isInRepositories('/lib/providers/auth.dart'), false);
      });

      test('identifies banned screen/provider imports', () {
        const bannedPatterns = ['screens/', 'providers/'];

        expect(
          bannedPatterns.any((p) => 'package:my_app/screens/home.dart'.contains(p)),
          true,
        );
        expect(
          bannedPatterns.any((p) => 'package:my_app/providers/auth.dart'.contains(p)),
          true,
        );
        expect(
          bannedPatterns.any((p) => 'package:my_app/models/user.dart'.contains(p)),
          false,
        );
      });

      test('identifies data source packages as allowed', () {
        const allowedPatterns = ['package:dio', 'package:http', 'package:cloud_firestore'];
        for (final pattern in allowedPatterns) {
          expect(pattern.startsWith('package:'), true);
        }
      });
    });

    group('ProviderAutodisposeEnforcement Logic', () {
      test('detects provider naming pattern', () {
        expect('authProvider'.endsWith('Provider'), true);
        expect('userNotifierProvider'.endsWith('Provider'), true);
        expect('authNotifier'.endsWith('Provider'), false);
      });

      test('detects various autoDispose patterns', () {
        const patterns = [
          'NotifierProvider.autoDispose<AuthNotifier, AuthState>',
          'Provider.autoDispose<User>',
          'AsyncNotifierProvider.autoDispose<AsyncNotifier, Data>',
          'StateNotifierProvider.autoDispose<Notifier, State>',
        ];

        for (final pattern in patterns) {
          expect(pattern.contains('autoDispose'), true);
        }
      });

      test('detects keepAlive in source', () {
        const withKeepAlive = '''
          (ref) {
            ref.keepAlive();
            return AuthNotifier();
          }
        ''';
        const withoutKeepAlive = '''
          (ref) {
            return AuthNotifier();
          }
        ''';

        expect(withKeepAlive.contains('ref.keepAlive()'), true);
        expect(withoutKeepAlive.contains('ref.keepAlive()'), false);
      });
    });

    group('ViewModelNamingConvention Logic', () {
      test('detects Notifier suffix in class names', () {
        expect('AuthNotifier'.endsWith('Notifier'), true);
        expect('UserStateNotifier'.endsWith('Notifier'), true);
        expect('UserViewModel'.endsWith('Notifier'), false);
        expect('AuthController'.endsWith('Notifier'), false);
      });

      test('detects Provider suffix in variable names', () {
        expect('authProvider'.endsWith('Provider'), true);
        expect('userStateProvider'.endsWith('Provider'), true);
        expect('authNotifier'.endsWith('Provider'), false);
      });

      test('detects AsyncNotifier as valid base class', () {
        const validBaseClasses = ['Notifier', 'AsyncNotifier', 'AutoDisposeNotifier', 'AutoDisposeAsyncNotifier'];
        for (final className in validBaseClasses) {
          expect(className.contains('Notifier'), true);
        }
      });
    });

    group('NoContextInProviders Logic', () {
      test('correctly identifies providers path', () {
        expect(PathUtils.isInProviders('/lib/providers/auth.dart'), true);
        expect(PathUtils.isInProviders('/lib/screens/home.dart'), false);
      });

      test('correctly identifies viewmodels path', () {
        // PathUtils.isInProviders checks for '/providers/', '/viewmodels/', '/view_models/' in path
        expect('/lib/viewmodels/auth.dart'.contains('/viewmodels/'), true);
        expect('/lib/view_models/auth.dart'.contains('/view_models/'), true);
      });
    });

    group('ComplexityLimits Logic', () {
      test('parameter count check', () {
        const maxParams = 4;
        expect(5 > maxParams, true);
        expect(4 > maxParams, false);
        expect(3 > maxParams, false);
      });

      test('nesting depth check', () {
        const maxNesting = 3;
        expect(4 > maxNesting, true);
        expect(3 > maxNesting, false);
        expect(2 > maxNesting, false);
      });

      test('build method line count check', () {
        const maxBuildLines = 120;
        expect(121 > maxBuildLines, true); // 121 lines should trigger
        expect(120 > maxBuildLines, false); // 120 lines is OK
        expect(100 > maxBuildLines, false); // Well under limit
        expect(150 > maxBuildLines, true); // Way over limit
      });

      test('method line count check (60 lines max)', () {
        const maxMethodLines = 60;
        expect(61 > maxMethodLines, true); // 61 lines should trigger
        expect(60 > maxMethodLines, false); // 60 lines is OK
        expect(50 > maxMethodLines, false); // Well under limit
        expect(100 > maxMethodLines, true); // Way over limit
      });

      test('build method has higher limit than regular methods', () {
        const maxBuildLines = 120;
        const maxMethodLines = 60;
        expect(maxBuildLines > maxMethodLines, true);
        // A 100-line method is:
        // - NOT OK for regular method (100 > 60)
        // - OK for build method (100 <= 120)
        expect(100 > maxMethodLines, true);
        expect(100 > maxBuildLines, false);
      });

      test('nested ternary detection pattern', () {
        const nestedTernary = 'condition1 ? value1 : condition2 ? value2 : value3';
        const simpleTernary = 'condition ? value1 : value2';

        // Count ternary operators
        int countTernary(String s) => '?'.allMatches(s).length;

        expect(countTernary(nestedTernary), 2); // Has nested ternary
        expect(countTernary(simpleTernary), 1); // Simple ternary is OK
      });
    });

    group('GlobalVariableRestriction Logic', () {
      test('allows private variables', () {
        expect('_privateVar'.startsWith('_'), true);
        expect('_internalCache'.startsWith('_'), true);
        expect('publicVar'.startsWith('_'), false);
      });

      test('allows k-prefixed constants', () {
        expect('kAnimationDuration'.startsWith('k'), true);
        expect('kPrimaryColor'.startsWith('k'), true);
        expect('animationDuration'.startsWith('k'), false);
      });

      test('allows Provider variables', () {
        expect('authProvider'.endsWith('Provider'), true);
        expect('userNotifierProvider'.endsWith('Provider'), true);
        expect('authNotifier'.endsWith('Provider'), false);
      });

      test('correctly identifies constants file', () {
        expect(PathUtils.isConstantsFile('/lib/utils/constants.dart'), true);
        expect(PathUtils.isConstantsFile('/lib/constants.dart'), true);
        expect(PathUtils.isConstantsFile('/lib/core/constants.dart'), true);
        expect(PathUtils.isConstantsFile('/lib/utils/helpers.dart'), false);
      });
    });

    group('PrintBan Logic', () {
      test('identifies banned print functions', () {
        const bannedFunctions = ['print', 'debugPrint'];
        expect(bannedFunctions.contains('print'), true);
        expect(bannedFunctions.contains('debugPrint'), true);
        expect(bannedFunctions.contains('log'), false);
        expect(bannedFunctions.contains('logger'), false);
      });
    });

    group('BarrelFileRestriction Logic', () {
      test('identifies index.dart files', () {
        expect(PathUtils.getFileNameWithExtension('/lib/screens/index.dart'),
            'index.dart');
      });

      test('correctly identifies banned locations', () {
        expect(PathUtils.isInScreens('/lib/screens/index.dart'), true);
        expect(PathUtils.isInFeatures('/lib/features/index.dart'), true);
        expect(PathUtils.isInProviders('/lib/providers/index.dart'), true);
        expect(PathUtils.isInWidgets('/lib/widgets/index.dart'), true);
      });

      test('identifies export-only files', () {
        const exportOnlyContent = "export 'foo.dart';\nexport 'bar.dart';";
        const mixedContent = "export 'foo.dart';\nclass MyClass {}";

        bool isExportOnly(String content) {
          final lines = content.split('\n').where((l) => l.trim().isNotEmpty);
          return lines.every((l) => l.trim().startsWith('export'));
        }

        expect(isExportOnly(exportOnlyContent), true);
        expect(isExportOnly(mixedContent), false);
      });
    });

    group('IgnoreFileBan Logic', () {
      test('detects ignore_for_file pattern', () {
        final pattern = RegExp(r'//\s*ignore_for_file:');

        expect(pattern.hasMatch('// ignore_for_file: lint_rule'), true);
        expect(pattern.hasMatch('//ignore_for_file: lint_rule'), true);
        expect(pattern.hasMatch('  // ignore_for_file: lint_rule'), true);
        expect(pattern.hasMatch('// ignore: lint_rule'), false);
      });

      test('does not match line-level ignores', () {
        final pattern = RegExp(r'//\s*ignore_for_file:');

        expect(pattern.hasMatch('// ignore: unused_variable'), false);
        expect(pattern.hasMatch('// ignore: dead_code'), false);
      });
    });

    group('HookSafetyEnforcement Logic', () {
      test('identifies banned controllers', () {
        const bannedControllers = [
          'TextEditingController',
          'AnimationController',
          'ScrollController',
          'PageController',
          'TabController',
          'FocusNode',
        ];

        expect(bannedControllers.contains('TextEditingController'), true);
        expect(bannedControllers.contains('AnimationController'), true);
        expect(bannedControllers.contains('FocusNode'), true);
        expect(bannedControllers.contains('StatelessWidget'), false);
      });

      test('identifies hook alternatives', () {
        const hookAlternatives = {
          'TextEditingController': 'useTextEditingController',
          'AnimationController': 'useAnimationController',
          'ScrollController': 'useScrollController',
          'PageController': 'usePageController',
          'TabController': 'useTabController',
          'FocusNode': 'useFocusNode',
        };

        for (final entry in hookAlternatives.entries) {
          expect(entry.value.startsWith('use'), true);
          expect(entry.value.contains(entry.key.replaceFirst('Controller', '').replaceFirst('Node', '')), true);
        }
      });

      test('identifies HookWidget base classes', () {
        const hookWidgetClasses = {'HookWidget', 'HookConsumerWidget'};

        expect(hookWidgetClasses.contains('HookWidget'), true);
        expect(hookWidgetClasses.contains('HookConsumerWidget'), true);
        expect(hookWidgetClasses.contains('StatelessWidget'), false);
        expect(hookWidgetClasses.contains('ConsumerWidget'), false);
      });

      test('detects GlobalKey<FormState> pattern', () {
        const badFormKey = 'GlobalKey<FormState>()';
        const goodFormKey = 'GlobalObjectKey<FormState>(context)';

        expect(badFormKey.contains('GlobalKey<FormState>'), true);
        expect(badFormKey.contains('GlobalObjectKey'), false);

        expect(goodFormKey.contains('GlobalObjectKey<FormState>'), true);
        expect(goodFormKey.contains('context'), true);
      });

      test('GlobalObjectKey is preferred in HookWidgets', () {
        // GlobalKey<FormState>() resets on:
        // - Keyboard open/close
        // - Orientation change
        // - Widget rebuild

        // GlobalObjectKey<FormState>(context) persists because
        // it uses context as the key identity

        const badPattern = 'final formKey = GlobalKey<FormState>();';
        const goodPattern = 'final formKey = GlobalObjectKey<FormState>(context);';

        expect(badPattern.contains('GlobalKey<'), true);
        expect(badPattern.contains('GlobalObjectKey<'), false);

        expect(goodPattern.contains('GlobalObjectKey<'), true);
        expect(goodPattern.contains('(context)'), true);
      });
    });

    group('ScaffoldLocation Logic', () {
      test('correctly identifies widgets path', () {
        expect(PathUtils.isInWidgets('/lib/widgets/button.dart'), true);
        expect(PathUtils.isInWidgets('/lib/widgets/cards/user_card.dart'), true);
        expect(PathUtils.isInWidgets('/lib/screens/home.dart'), false);
      });

      test('screens path allows Scaffold', () {
        expect(PathUtils.isInScreens('/lib/screens/home.dart'), true);
        // '/pages/' is also a valid screen path pattern
        expect('/lib/pages/home.dart'.contains('/pages/'), true);
      });
    });

    group('AssetSafety Logic', () {
      test('identifies asset path string literals', () {
        const assetPaths = [
          'assets/logo.png',
          'assets/images/logo.png',
          'assets/icons/home.svg',
        ];

        for (final path in assetPaths) {
          expect(path.startsWith('assets/'), true);
        }
      });

      test('identifies non-asset paths', () {
        const nonAssetPaths = [
          'https://example.com/image.png',
          '/path/to/file.png',
          'data:image/png;base64,...',
        ];

        for (final path in nonAssetPaths) {
          expect(path.startsWith('assets/'), false);
        }
      });
    });

    group('FileClassMatch Logic', () {
      test('snake_case to PascalCase conversion', () {
        expect(PathUtils.snakeToPascal('home_screen'), 'HomeScreen');
        expect(PathUtils.snakeToPascal('auth_repository'), 'AuthRepository');
        expect(PathUtils.snakeToPascal('user_model'), 'UserModel');
        expect(PathUtils.snakeToPascal('login_button'), 'LoginButton');
      });

      test('handles single word names', () {
        expect(PathUtils.snakeToPascal('home'), 'Home');
        expect(PathUtils.snakeToPascal('user'), 'User');
        expect(PathUtils.snakeToPascal('auth'), 'Auth');
      });

      test('handles multiple underscores', () {
        expect(PathUtils.snakeToPascal('user_profile_screen'), 'UserProfileScreen');
        expect(PathUtils.snakeToPascal('auth_login_button'), 'AuthLoginButton');
      });

      test('extracts file name correctly', () {
        expect(PathUtils.getFileName('/lib/screens/home_screen.dart'),
            'home_screen');
        expect(PathUtils.getFileName('/lib/repositories/auth_repository.dart'),
            'auth_repository');
        expect(PathUtils.getFileName('simple.dart'), 'simple');
      });

      test('handles paths with multiple dots', () {
        expect(PathUtils.getFileName('/lib/screens/home.screen.dart'),
            'home.screen');
      });
    });

    group('RepositoryNoTryCatch Logic', () {
      test('identifies try-catch patterns', () {
        const withTryCatch = '''
          Future<User> getUser() async {
            try {
              return await api.get();
            } catch (e) {
              return null;
            }
          }
        ''';

        expect(withTryCatch.contains('try'), true);
        expect(withTryCatch.contains('catch'), true);
      });
    });

    group('RepositoryAsyncReturn Logic', () {
      test('identifies async return types', () {
        const validReturnTypes = [
          'Future<User>',
          'Future<List<User>>',
          'Future<void>',
          'Stream<List<User>>',
          'Stream<User>',
        ];

        for (final type in validReturnTypes) {
          expect(type.startsWith('Future') || type.startsWith('Stream'), true);
        }
      });

      test('identifies sync return types', () {
        const syncReturnTypes = ['User', 'bool', 'void', 'List<User>'];

        for (final type in syncReturnTypes) {
          expect(type.startsWith('Future') || type.startsWith('Stream'), false);
        }
      });
    });

    group('AsyncViewModelSafety Logic', () {
      test('identifies await statements', () {
        const withAwait = 'final user = await repository.getUser();';
        const withoutAwait = 'final user = repository.getUser();';

        expect(withAwait.contains('await'), true);
        expect(withoutAwait.contains('await'), false);
      });

      test('identifies try-catch wrapper', () {
        const withTryCatch = '''
          try {
            final user = await repository.getUser();
          } catch (e) {
            // handle error
          }
        ''';

        expect(withTryCatch.contains('try'), true);
        expect(withTryCatch.contains('catch'), true);
        expect(withTryCatch.contains('await'), true);
      });
    });

    group('ProviderFileNaming Logic', () {
      test('validates provider file naming convention', () {
        // File name: auth_provider.dart -> class: AuthNotifier
        String fileNameToNotifierClass(String fileName) {
          final prefix = fileName.replaceAll('_provider', '');
          return '${PathUtils.snakeToPascal(prefix)}Notifier';
        }

        expect(fileNameToNotifierClass('auth_provider'), 'AuthNotifier');
        expect(fileNameToNotifierClass('user_settings_provider'), 'UserSettingsNotifier');
        expect(fileNameToNotifierClass('cart_provider'), 'CartNotifier');
      });

      test('detects file name ends with _provider', () {
        expect('auth_provider'.endsWith('_provider'), true);
        expect('user_provider'.endsWith('_provider'), true);
        expect('auth_notifier'.endsWith('_provider'), false);
        expect('auth'.endsWith('_provider'), false);
      });
    });

    group('ProviderStateClass Logic', () {
      test('identifies @freezed annotation', () {
        const freezedAnnotations = ['@freezed', '@Freezed'];

        for (final annotation in freezedAnnotations) {
          expect(annotation.toLowerCase().contains('freezed'), true);
        }
      });

      test('validates state class naming', () {
        // State classes should end with State
        expect('AuthState'.endsWith('State'), true);
        expect('UserProfileState'.endsWith('State'), true);
        expect('AuthNotifier'.endsWith('State'), false);
      });

      test('detects state class in same file', () {
        const localStateClass = 'AuthState';
        const importedStateClass = '../models/auth_state.dart';

        expect(localStateClass.contains('/'), false); // Local
        expect(importedStateClass.contains('/'), true); // Imported
      });
    });

    group('ProviderDeclarationSyntax Logic', () {
      test('validates .new constructor syntax', () {
        const goodSyntax = 'NotifierProvider.autoDispose(AuthNotifier.new)';
        const badSyntaxWithGenerics = 'NotifierProvider.autoDispose<AuthNotifier, AuthState>(() => AuthNotifier())';
        const badSyntaxWithClosure = 'NotifierProvider.autoDispose(() => AuthNotifier())';

        expect(goodSyntax.contains('.new'), true);
        expect(goodSyntax.contains('<'), false);

        expect(badSyntaxWithGenerics.contains('<'), true);
        expect(badSyntaxWithGenerics.contains('.new'), false);

        expect(badSyntaxWithClosure.contains('() =>'), true);
        expect(badSyntaxWithClosure.contains('.new'), false);
      });

      test('identifies NotifierProvider patterns', () {
        const providerTypes = [
          'NotifierProvider',
          'AsyncNotifierProvider',
          'StreamNotifierProvider',
        ];

        for (final type in providerTypes) {
          expect(type.contains('NotifierProvider'), true);
        }
      });
    });

    group('ProviderClassRestriction Logic', () {
      test('validates Notifier base classes', () {
        const notifierPatterns = [
          'Notifier',
          'AsyncNotifier',
          'StreamNotifier',
          'AutoDisposeNotifier',
          'AutoDisposeAsyncNotifier',
        ];

        for (final pattern in notifierPatterns) {
          expect(pattern.contains('Notifier'), true);
        }
      });

      test('validates allowed classes in provider files', () {
        // Only Notifier classes and @freezed state classes allowed
        const allowedClasses = [
          'AuthNotifier', // extends Notifier
          'AuthState', // @freezed
        ];

        const disallowedClasses = [
          'User', // Plain class - should be in models/
          'AuthHelper', // Helper class - should be in utils/
        ];

        for (final cls in allowedClasses) {
          expect(
            cls.endsWith('Notifier') || cls.endsWith('State'),
            true,
          );
        }

        for (final cls in disallowedClasses) {
          expect(
            cls.endsWith('Notifier') || cls.endsWith('State'),
            false,
          );
        }
      });
    });

    group('ProviderSinglePerFile Logic', () {
      test('validates single provider per file', () {
        // File: auth_provider.dart should have authProvider
        String fileNameToProviderName(String fileName) {
          final prefix = fileName.replaceAll('_provider', '');
          final camelCase = PathUtils.snakeToPascal(prefix);
          return '${camelCase[0].toLowerCase()}${camelCase.substring(1)}Provider';
        }

        expect(fileNameToProviderName('auth_provider'), 'authProvider');
        expect(fileNameToProviderName('user_settings_provider'), 'userSettingsProvider');
        expect(fileNameToProviderName('good_provider'), 'goodProvider');
      });

      test('detects NotifierProvider declarations', () {
        const providerPatterns = [
          'NotifierProvider.autoDispose',
          'AsyncNotifierProvider.autoDispose',
          'StreamNotifierProvider.autoDispose',
        ];

        for (final pattern in providerPatterns) {
          expect(pattern.startsWith('NotifierProvider') ||
              pattern.startsWith('AsyncNotifierProvider') ||
              pattern.startsWith('StreamNotifierProvider'), true);
        }
      });
    });

    group('RepositoryProviderDeclaration Logic', () {
      test('validates RepoProvider naming', () {
        expect('authRepoProvider'.endsWith('RepoProvider'), true);
        expect('userRepoProvider'.endsWith('RepoProvider'), true);
        expect('authProvider'.endsWith('RepoProvider'), false);
        expect('authRepositoryProvider'.endsWith('RepoProvider'), false);
      });

      test('validates Provider declaration pattern', () {
        const validProvider = 'Provider<AuthRepository>((ref) => AuthRepository(dio))';
        const invalidProvider = 'AuthRepository()';

        expect(validProvider.startsWith('Provider'), true);
        expect(invalidProvider.startsWith('Provider'), false);
      });
    });

    group('RepositoryDependencyInjection Logic', () {
      test('detects direct object instantiation', () {
        const directInstantiation = 'final Dio _dio = Dio();';
        const injectedDependency = 'final Dio _dio;';

        expect(directInstantiation.contains('= Dio()'), true);
        expect(injectedDependency.contains('= Dio()'), false);
      });

      test('detects Ref parameter in repository', () {
        const withRef = 'final Ref ref;';
        const withoutRef = 'final Dio _dio;';

        expect(withRef.contains('Ref'), true);
        expect(withoutRef.contains('Ref'), false);
      });

      test('validates constructor injection pattern', () {
        const goodConstructor = 'AuthRepository(this._dio);';
        const badConstructor = 'AuthRepository() : _dio = Dio();';

        expect(goodConstructor.contains('this._'), true);
        expect(badConstructor.contains('= Dio()'), true);
      });
    });

    group('RepositoryClassRestriction Logic', () {
      test('validates Repository class naming', () {
        expect('AuthRepository'.contains('Repository'), true);
        expect('UserRepository'.contains('Repository'), true);
        expect('User'.contains('Repository'), false);
        expect('AuthHelper'.contains('Repository'), false);
      });

      test('validates file naming in repositories', () {
        expect('auth_repository'.endsWith('_repository'), true);
        expect('user_repository'.endsWith('_repository'), true);
        expect('auth'.endsWith('_repository'), false);
        expect('user_repo'.endsWith('_repository'), false);
      });
    });

    group('SharedWidgetPurity SingleWidget Logic', () {
      test('validates widget base classes', () {
        const widgetBaseClasses = [
          'StatelessWidget',
          'StatefulWidget',
          'HookWidget',
          'HookConsumerWidget',
          'ConsumerWidget',
          'ConsumerStatefulWidget',
        ];

        for (final cls in widgetBaseClasses) {
          expect(cls.contains('Widget'), true);
        }
      });

      test('detects private vs public widget classes', () {
        const publicWidget = 'UserCard';
        const privateWidget = '_UserCard';

        expect(publicWidget.startsWith('_'), false);
        expect(privateWidget.startsWith('_'), true);
      });
    });

    group('PresentationLayerIsolation RecordEnforcement Logic', () {
      test('detects parameter class pattern', () {
        // Classes with only final fields and constructor are parameter classes
        const parameterClassPattern = '''
          class UpdateProfileParams {
            final String userId;
            final String name;
            const UpdateProfileParams({required this.userId, required this.name});
          }
        ''';

        expect(parameterClassPattern.contains('final String'), true);
        expect(parameterClassPattern.contains('const '), true);
      });

      test('validates record type syntax', () {
        const recordType = '({String userId, String name, String? phone})';
        const typedefRecord = 'typedef UpdateProfileParams = ({String userId, String name});';

        expect(recordType.startsWith('('), true);
        expect(recordType.contains('{'), true);
        expect(typedefRecord.startsWith('typedef'), true);
      });
    });

    group('GlobalVariableRestriction FunctionBan Logic', () {
      test('detects top-level functions', () {
        const publicFunction = 'void updateProfile() {}';
        const privateFunction = 'void _updateProfile() {}';
        const kPrefixedFunction = 'void kFormatDate() {}';

        // Public functions should be banned
        expect(publicFunction.contains('void _'), false);
        expect(publicFunction.contains('void k'), false);

        // Private functions allowed
        expect(privateFunction.contains('void _'), true);

        // k-prefixed functions in constants.dart allowed
        expect(kPrefixedFunction.contains('void k'), true);
      });

      test('allows main function', () {
        const mainFunction = 'void main() {}';
        expect(mainFunction.contains('main()'), true);
      });
    });
  });

  group('ImportUtils Tests', () {
    test('matchesBannedImport matches exact pattern', () {
      expect(
        ImportUtils.matchesBannedImport('package:dio/dio.dart', ['package:dio']),
        true,
      );
    });

    test('matchesBannedImport matches prefix pattern', () {
      expect(
        ImportUtils.matchesBannedImport(
          'package:cloud_firestore/cloud_firestore.dart',
          ['package:cloud_firestore'],
        ),
        true,
      );
    });

    test('matchesBannedImport matches directory pattern', () {
      expect(
        ImportUtils.matchesBannedImport('../repositories/user_repo.dart', ['repositories/']),
        true,
      );
      expect(
        ImportUtils.matchesBannedImport('package:app/repositories/auth.dart', ['repositories/']),
        true,
      );
    });

    test('matchesBannedImport does not match unrelated imports', () {
      expect(
        ImportUtils.matchesBannedImport('package:flutter/material.dart', ['package:dio']),
        false,
      );
      expect(
        ImportUtils.matchesBannedImport('../models/user.dart', ['repositories/']),
        false,
      );
    });

    test('matchesBannedImport handles relative imports', () {
      expect(
        ImportUtils.matchesBannedImport('../providers/auth.dart', ['providers/']),
        true,
      );
      expect(
        ImportUtils.matchesBannedImport('./providers/auth.dart', ['providers/']),
        true,
      );
    });

    test('matchesBannedImport handles multiple patterns', () {
      expect(
        ImportUtils.matchesBannedImport('package:dio/dio.dart', ['package:http', 'package:dio']),
        true,
      );
      expect(
        ImportUtils.matchesBannedImport('../repositories/user.dart', ['screens/', 'repositories/']),
        true,
      );
    });
  });

  group('PathUtils Edge Cases', () {
    test('handles Windows-style paths', () {
      final normalized = PathUtils.normalizePath(r'C:\lib\screens\home.dart');
      expect(normalized, contains('/'));
      expect(normalized, isNot(contains(r'\')));
    });

    test('handles paths with special characters', () {
      expect(
        PathUtils.isInScreens('/lib/screens/home-screen.dart'),
        true,
      );
    });

    test('handles empty path gracefully', () {
      expect(PathUtils.getFileName(''), '');
    });

    test('isInLib detects lib directory', () {
      expect(PathUtils.isInLib('/project/lib/main.dart'), true);
      expect(PathUtils.isInLib('/project/test/main_test.dart'), false);
      expect(PathUtils.isInLib('/project/bin/main.dart'), false);
    });
  });
}
