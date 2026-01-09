import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../utils.dart';

/// Rule: repository_class_restriction
///
/// Repository files should only contain Repository classes.
/// Any other class declarations (like models, helpers, etc.)
/// should be in their appropriate directories (models/, utils/, etc.).
///
/// Also enforces that files in repositories/ must end with _repository.dart
class RepositoryClassRestriction extends DartLintRule {
  const RepositoryClassRestriction() : super(code: _classCode);

  static const _classCode = LintCode(
    name: 'repository_class_restriction',
    problemMessage:
        'Repository files should only contain classes with "Repository" in the name.',
    correctionMessage:
        'Move this class to the appropriate directory (models/, utils/, etc.).',
  );

  static const _fileNameCode = LintCode(
    name: 'repository_class_restriction',
    problemMessage: 'Files in repositories/ must end with _repository.dart.',
    correctionMessage:
        'Rename the file to end with _repository.dart (e.g., auth_repository.dart).',
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    // Only apply to files in repositories directory
    if (!PathUtils.isInRepositories(resolver.path)) {
      return;
    }

    final fileName = PathUtils.getFileName(resolver.path);

    // Check file naming
    bool hasReportedFileNameError = false;

    context.registry.addClassDeclaration((node) {
      final className = node.name.lexeme;

      // Skip private classes
      if (className.startsWith('_')) return;

      // First, check if file name is correct (only report once)
      if (!fileName.endsWith('_repository') && !hasReportedFileNameError) {
        reporter.atToken(node.name, _fileNameCode);
        hasReportedFileNameError = true;
      }

      // Check if class name contains "Repository"
      if (!className.contains('Repository')) {
        reporter.atToken(node.name, _classCode);
      }
    });
  }
}
