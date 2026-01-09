import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../utils.dart';

/// Rule: provider_file_naming
///
/// Enforce naming conventions in providers directory:
/// - File names must end with _provider.dart (e.g., auth_provider.dart)
/// - File must contain a Notifier class with matching prefix (e.g., AuthNotifier)
class ProviderFileNaming extends DartLintRule {
  const ProviderFileNaming() : super(code: _fileCode);

  static const _fileCode = LintCode(
    name: 'provider_file_naming',
    problemMessage:
        'Provider files must end with _provider.dart and contain a matching Notifier class.',
    correctionMessage:
        'Rename file to {name}_provider.dart and ensure it has a {Name}Notifier class.',
  );

  static const _notifierMissingCode = LintCode(
    name: 'provider_file_naming',
    problemMessage:
        'Provider file must contain a Notifier class with matching prefix (e.g., auth_provider.dart should have AuthNotifier).',
    correctionMessage:
        'Add a Notifier class that matches the file name prefix (e.g., AuthNotifier for auth_provider.dart).',
  );

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

    // Skip index.dart and other special files
    if (fileName == 'index' || fileName.startsWith('_')) {
      return;
    }

    // Check if file ends with _provider
    if (!fileName.endsWith('_provider')) {
      // Report on the first class or first line
      context.registry.addClassDeclaration((node) {
        if (!node.name.lexeme.startsWith('_')) {
          reporter.atToken(node.name, _fileCode);
        }
      });
      return;
    }

    // Extract the prefix (e.g., "auth" from "auth_provider")
    final prefix = fileName.replaceAll('_provider', '');
    final expectedNotifierPrefix = PathUtils.snakeToPascal(prefix);

    // Collect all Notifier classes
    final notifierClasses = <String>[];
    ClassDeclaration? firstClass;

    context.registry.addClassDeclaration((node) {
      final className = node.name.lexeme;
      if (className.startsWith('_')) return;

      firstClass ??= node;

      // Check if it's a Notifier class
      final extendsClause = node.extendsClause;
      if (extendsClause != null) {
        final superclassName = extendsClause.superclass.name2.lexeme;
        if (superclassName.contains('Notifier')) {
          notifierClasses.add(className);
        }
      }
    });

    // After all classes are collected, check if any Notifier matches the file name prefix
    context.addPostRunCallback(() {
      if (notifierClasses.isEmpty) return;

      // Check if any Notifier class starts with the expected prefix
      final hasMatchingNotifier = notifierClasses.any((name) =>
          name.startsWith(expectedNotifierPrefix) && name.endsWith('Notifier'));

      if (!hasMatchingNotifier && firstClass != null) {
        reporter.atToken(firstClass!.name, _notifierMissingCode);
      }
    });
  }
}
