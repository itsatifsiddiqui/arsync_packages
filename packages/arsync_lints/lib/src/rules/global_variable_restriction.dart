import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../utils.dart';

/// Rule D2: global_variable_restriction
///
/// No global state pollution.
/// Variables allowed:
/// - Variables starting with _ (file-private)
/// - Variables starting with k (constants in constants.dart)
/// - Riverpod Providers (variables ending in Provider in lib/providers/ or lib/repositories/)
///
/// Functions allowed:
/// - Functions starting with _ (file-private)
/// - Functions starting with k (utility functions in constants.dart)
class GlobalVariableRestriction extends DartLintRule {
  const GlobalVariableRestriction() : super(code: _variableCode);

  static const _variableCode = LintCode(
    name: 'global_variable_restriction',
    problemMessage:
        'Top-level variables must be private (_), constants (k prefix in constants.dart), or Providers.',
    correctionMessage:
        'Make the variable private with _ prefix, move to constants.dart with k prefix, or use a Provider.',
  );

  static const _functionCode = LintCode(
    name: 'global_variable_restriction',
    problemMessage:
        'Top-level functions must be private (_) or defined in constants.dart with k prefix.',
    correctionMessage:
        'Make the function private with _ prefix, move to a class, or move to constants.dart with k prefix.',
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    // Only apply to lib/ files
    if (!PathUtils.isInLib(resolver.path)) {
      return;
    }

    final isConstantsFile = PathUtils.isConstantsFile(resolver.path);
    final isProvidersFile = PathUtils.isInProviders(resolver.path);
    final isRepositoriesFile = PathUtils.isInRepositories(resolver.path);

    // Check top-level variables
    context.registry.addTopLevelVariableDeclaration((node) {
      for (final variable in node.variables.variables) {
        final name = variable.name.lexeme;

        // Skip private variables
        if (name.startsWith('_')) continue;

        // Allow k-prefixed variables in constants.dart
        if (isConstantsFile && name.startsWith('k')) continue;

        // Allow Providers in lib/providers/ (includes providers/core/)
        if (isProvidersFile && name.endsWith('Provider')) continue;

        // Allow Providers in lib/repositories/ (RepoProvider)
        if (isRepositoriesFile && name.endsWith('Provider')) continue;

        // Everything else is an error
        reporter.atToken(variable.name, _variableCode);
      }
    });

    // Check top-level functions
    context.registry.addFunctionDeclaration((node) {
      final name = node.name.lexeme;

      // Skip private functions
      if (name.startsWith('_')) return;

      // Allow k-prefixed functions in constants.dart
      if (isConstantsFile && name.startsWith('k')) return;

      // Allow main function
      if (name == 'main') return;

      // Everything else is an error
      reporter.atToken(node.name, _functionCode);
    });
  }
}
