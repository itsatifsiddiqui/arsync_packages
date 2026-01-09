import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../utils.dart';

/// Rule: provider_single_per_file
///
/// Each provider file should only contain ONE NotifierProvider that matches
/// the file name.
///
/// Good: auth_provider.dart contains only authProvider + AuthNotifier + AuthState
/// Bad: auth_provider.dart contains authProvider, userProvider, settingsProvider
class ProviderSinglePerFile extends DartLintRule {
  const ProviderSinglePerFile() : super(code: _multipleProvidersCode);

  static const _multipleProvidersCode = LintCode(
    name: 'provider_single_per_file',
    problemMessage:
        'Provider file should only contain ONE NotifierProvider. '
        'Move additional providers to their own files.',
    correctionMessage:
        'Create a separate file for this provider (e.g., user_provider.dart for userProvider).',
  );

  static const _nameMismatchCode = LintCode(
    name: 'provider_single_per_file',
    problemMessage:
        'Provider variable name does not match file name.',
    correctionMessage:
        'Rename the provider to match the file name '
        '(e.g., auth_provider.dart should have authProvider).',
  );

  /// Provider type patterns to detect
  static const _providerPatterns = {
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

    final fileName = PathUtils.getFileName(resolver.path);

    // Skip if file doesn't end with _provider
    if (!fileName.endsWith('_provider')) {
      return;
    }

    // Extract the expected provider name prefix (e.g., "auth" from "auth_provider")
    final prefix = fileName.replaceAll('_provider', '');
    final expectedProviderName = '${_snakeToCamel(prefix)}Provider';

    // Collect all NotifierProvider declarations
    final providerDeclarations = <VariableDeclaration>[];

    context.registry.addTopLevelVariableDeclaration((node) {
      for (final variable in node.variables.variables) {
        final initializer = variable.initializer;
        if (initializer == null) continue;

        // Check if this is a NotifierProvider
        final source = initializer.toSource();
        final isNotifierProvider = _providerPatterns.any(
          (pattern) => source.startsWith(pattern),
        );

        if (isNotifierProvider) {
          providerDeclarations.add(variable);
        }
      }
    });

    // After collecting all providers, validate
    context.addPostRunCallback(() {
      if (providerDeclarations.isEmpty) return;

      // Check for multiple providers
      if (providerDeclarations.length > 1) {
        // Report on all providers after the first one
        for (var i = 1; i < providerDeclarations.length; i++) {
          reporter.atToken(
            providerDeclarations[i].name,
            _multipleProvidersCode,
          );
        }
      }

      // Check if the first/main provider matches the file name
      final mainProvider = providerDeclarations.first;
      final providerName = mainProvider.name.lexeme;

      if (providerName != expectedProviderName) {
        reporter.atToken(mainProvider.name, _nameMismatchCode);
      }
    });
  }

  /// Convert snake_case to camelCase
  String _snakeToCamel(String snake) {
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
}
