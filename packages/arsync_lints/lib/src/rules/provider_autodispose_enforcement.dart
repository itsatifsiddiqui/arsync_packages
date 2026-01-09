import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../utils.dart';

/// Rule B1: provider_autodispose_enforcement
///
/// To prevent memory leaks, all providers must use .autoDispose by default.
/// Exception: providers/core/ contains infrastructure providers (Dio, etc.)
/// that should persist throughout the app lifecycle.
class ProviderAutodisposeEnforcement extends DartLintRule {
  const ProviderAutodisposeEnforcement() : super(code: _code);

  static const _code = LintCode(
    name: 'provider_autodispose_enforcement',
    problemMessage:
        'Providers must use .autoDispose to prevent memory leaks.',
    correctionMessage:
        'Add .autoDispose to the provider or call ref.keepAlive() inside it.',
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    // Only apply to files in lib/providers/
    if (!PathUtils.isInProviders(resolver.path)) {
      return;
    }

    // Skip providers/core/ - infrastructure providers that should persist
    if (resolver.path.contains('providers/core/')) {
      return;
    }

    context.registry.addTopLevelVariableDeclaration((node) {
      for (final variable in node.variables.variables) {
        final name = variable.name.lexeme;

        // Check if variable name ends with 'Provider'
        if (!name.endsWith('Provider')) continue;

        final initializer = variable.initializer;
        if (initializer == null) continue;

        // Get the source code of the initializer
        final initializerSource = initializer.toSource();

        // Check if it uses autoDispose
        final hasAutoDispose = initializerSource.contains('autoDispose') ||
            initializerSource.contains('.autoDispose');

        // Check if ref.keepAlive() is called inside the provider
        final hasKeepAlive = _containsKeepAlive(initializer);

        if (!hasAutoDispose && !hasKeepAlive) {
          reporter.atToken(variable.name, _code);
        }
      }
    });
  }

  /// Recursively checks if the expression contains ref.keepAlive() call.
  bool _containsKeepAlive(Expression? expression) {
    if (expression == null) return false;

    // Check the source for keepAlive
    final source = expression.toSource();
    return source.contains('ref.keepAlive()') ||
        source.contains('ref.keepAlive(');
  }
}
