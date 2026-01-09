import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../utils.dart';

/// Rule D4: barrel_file_restriction
///
/// Explicit imports are preferred to maintain layer visibility.
/// Banned in: lib/screens/, lib/features/, lib/providers/
/// Allowed in: lib/utils/, lib/widgets/, lib/models/
class BarrelFileRestriction extends DartLintRule {
  const BarrelFileRestriction() : super(code: _code);

  static const _code = LintCode(
    name: 'barrel_file_restriction',
    problemMessage:
        'Barrel files (index.dart or export-only files) are not allowed in screens, features, or providers folders.',
    correctionMessage: 'Use explicit imports instead of barrel files.',
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    final filePath = resolver.path;
    final fileName = PathUtils.getFileNameWithExtension(filePath);

    // Check if file is in banned locations
    final isInBannedLocation = PathUtils.isInScreens(filePath) ||
        PathUtils.isInFeatures(filePath) ||
        PathUtils.isInProviders(filePath);

    if (!isInBannedLocation) return;

    // Check if file is named index.dart
    if (fileName == 'index.dart') {
      context.registry.addCompilationUnit((node) {
        reporter.atNode(node, _code);
      });
      return;
    }

    // Check if file only contains export statements
    context.registry.addCompilationUnit((node) {
      final directives = node.directives;
      final declarations = node.declarations;

      // If file has no declarations and only has export directives
      if (declarations.isEmpty) {
        final hasOnlyExports = directives.every((directive) =>
            directive is ExportDirective || directive is LibraryDirective);

        final hasExports =
            directives.any((directive) => directive is ExportDirective);

        if (hasOnlyExports && hasExports) {
          reporter.atNode(node, _code);
        }
      }
    });
  }
}
