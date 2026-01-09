import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../utils.dart';

/// Rule E4: file_class_match
///
/// Enforce strict naming correspondence.
/// If file is login_screen.dart, at least one Class MUST be LoginScreen.
/// If file is auth_repository.dart, at least one Class MUST be AuthRepository.
/// Files can contain multiple classes, but at least one must match the file name.
class FileClassMatch extends DartLintRule {
  const FileClassMatch() : super(code: _code);

  static const _code = LintCode(
    name: 'file_class_match',
    problemMessage:
        'No class in this file matches the file name. Expected a class named like the file (snake_case to PascalCase).',
    correctionMessage:
        'Add or rename a class to match the file name (e.g., login_screen.dart should have LoginScreen class).',
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

    // Skip providers directory - it has special naming rules
    // (files end with _provider.dart but classes end with Notifier)
    if (PathUtils.isInProviders(resolver.path)) {
      return;
    }

    final fileName = PathUtils.getFileName(resolver.path);
    final expectedClassName = PathUtils.snakeToPascal(fileName);

    // Collect all class declarations in the file
    final classNames = <String>[];
    ClassDeclaration? firstClass;

    context.registry.addClassDeclaration((node) {
      final className = node.name.lexeme;

      // Skip private classes
      if (className.startsWith('_')) return;

      classNames.add(className);
      firstClass ??= node;
    });

    // After all classes are collected, check if any matches
    context.addPostRunCallback(() {
      if (classNames.isEmpty) return;

      // Check if any public class matches the expected name
      final hasMatchingClass = classNames.any((name) => name == expectedClassName);

      if (!hasMatchingClass && firstClass != null) {
        // Report on the first class as a representative location
        reporter.atToken(firstClass!.name, _code);
      }
    });
  }
}
