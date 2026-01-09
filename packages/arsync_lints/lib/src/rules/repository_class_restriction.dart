import 'package:analyzer/source/line_info.dart';

import '../arsync_lint_rule.dart';

/// Rule: repository_class_restriction
///
/// Repository files should only contain Repository classes.
/// Any other class declarations (like models, helpers, etc.)
/// should be in their appropriate directories (models/, utils/, etc.).
///
/// Also enforces that files in repositories/ must end with _repository.dart
class RepositoryClassRestriction extends MultiAnalysisRule {
  RepositoryClassRestriction()
      : super(
          name: 'repository_class_restriction',
          description:
              'Repository files should only contain classes with "Repository" in the name.',
        );

  static const classCode = LintCode(
    'repository_class_restriction',
    'Repository files should only contain classes with "Repository" in the name.',
    correctionMessage:
        'Move this class to the appropriate directory (models/, utils/, etc.).',
  );

  static const fileNameCode = LintCode(
    'repository_class_restriction',
    'Files in repositories/ must end with _repository.dart.',
    correctionMessage:
        'Rename the file to end with _repository.dart (e.g., auth_repository.dart).',
  );

  @override
  List<DiagnosticCode> get diagnosticCodes => [classCode, fileNameCode];

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    final path = context.definingUnit.file.path;
    if (!PathUtils.isInRepositories(path)) {
      return;
    }

    final fileName = PathUtils.getFileName(path);

    final content = context.definingUnit.content;
    final lineInfo = LineInfo.fromContent(content);

    final visitor = _Visitor(this, fileName, content, lineInfo);
    registry.addCompilationUnit(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final MultiAnalysisRule rule;
  final String fileName;
  final String content;
  final LineInfo lineInfo;

  _Visitor(this.rule, this.fileName, this.content, this.lineInfo);

  @override
  void visitCompilationUnit(CompilationUnit node) {
    bool hasReportedFileNameError = false;

    for (final declaration in node.declarations) {
      if (declaration is ClassDeclaration) {
        final className = declaration.name.lexeme;

        // Skip private classes
        if (className.startsWith('_')) continue;

        // First, check if file name is correct (only report once)
        if (!fileName.endsWith('_repository') && !hasReportedFileNameError) {
          if (!IgnoreUtils.shouldIgnoreAtOffset(
            offset: declaration.name.offset,
            lintName: 'repository_class_restriction',
            content: content,
            lineInfo: lineInfo,
          )) {
            rule.reportAtOffset(
              declaration.name.offset,
              declaration.name.length,
              diagnosticCode: RepositoryClassRestriction.fileNameCode,
            );
          }
          hasReportedFileNameError = true;
        }

        // Check if class name contains "Repository"
        if (!className.contains('Repository')) {
          if (IgnoreUtils.shouldIgnoreAtOffset(
            offset: declaration.name.offset,
            lintName: 'repository_class_restriction',
            content: content,
            lineInfo: lineInfo,
          )) {
            continue;
          }
          rule.reportAtOffset(
            declaration.name.offset,
            declaration.name.length,
            diagnosticCode: RepositoryClassRestriction.classCode,
          );
        }
      }
    }
  }
}
