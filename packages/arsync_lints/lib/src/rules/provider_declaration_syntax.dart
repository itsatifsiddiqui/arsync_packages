import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../utils.dart';

/// Rule: provider_declaration_syntax
///
/// Enforce clean provider declaration syntax:
/// 1. NotifierProvider must use .new constructor syntax (e.g., AuthNotifier.new)
/// 2. NotifierProvider must not have explicit generic type parameters
///
/// Good: `final authProvider = NotifierProvider.autoDispose(AuthNotifier.new);`
/// Bad:  `final authProvider = NotifierProvider.autoDispose<AuthNotifier, AuthState>(() => AuthNotifier());`
class ProviderDeclarationSyntax extends DartLintRule {
  const ProviderDeclarationSyntax() : super(code: _code);

  static const _code = LintCode(
    name: 'provider_declaration_syntax',
    problemMessage:
        'NotifierProvider should use .new constructor syntax without explicit generic parameters.',
    correctionMessage:
        'Use NotifierProvider.autoDispose(MyNotifier.new) instead of '
        'NotifierProvider.autoDispose<MyNotifier, State>(() => MyNotifier()).',
  );

  /// Provider types that should use .new syntax
  static const _notifierProviderTypes = {
    'NotifierProvider',
    'AsyncNotifierProvider',
    'StreamNotifierProvider',
  };

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    // Only apply to files in providers directory
    if (!PathUtils.isInProviders(resolver.path)) {
      return;
    }

    // Listen to top-level variable declarations (provider declarations)
    context.registry.addTopLevelVariableDeclaration((node) {
      for (final variable in node.variables.variables) {
        final initializer = variable.initializer;
        if (initializer == null) continue;

        _checkProviderSyntax(initializer, reporter);
      }
    });

    // Also listen for FieldDeclarations (class-level providers)
    context.registry.addFieldDeclaration((node) {
      for (final variable in node.fields.variables) {
        final initializer = variable.initializer;
        if (initializer == null) continue;

        _checkProviderSyntax(initializer, reporter);
      }
    });
  }

  void _checkProviderSyntax(Expression initializer, ErrorReporter reporter) {
    // Check if this is a NotifierProvider/AsyncNotifierProvider call with bad syntax
    final source = initializer.toSource();
    final isTargetedProvider = _notifierProviderTypes.any(
      (type) => source.startsWith(type),
    );

    if (!isTargetedProvider) return;

    // Bad patterns:
    // 1. Has type args (like <A, B>) - should not have explicit generics
    // 2. Uses closure instead of .new - should use constructor tear-off
    final hasTypeArgs = source.contains('<') && source.contains('>');
    final usesClosureInsteadOfNew = !source.contains('.new') &&
        (source.contains('() {') || source.contains('() =>'));

    if (hasTypeArgs || usesClosureInsteadOfNew) {
      reporter.atNode(initializer, _code);
    }
  }
}
