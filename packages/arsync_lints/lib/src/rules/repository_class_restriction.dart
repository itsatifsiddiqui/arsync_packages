import '../arsync_lint_rule.dart';

/// Rule: in `lib/repositories/`, public classes must contain "Repository" in
/// their name and the file must end with `_repository.dart`.
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
    if (!PathUtils.isInRepositories(path)) return;
    registry.addCompilationUnit(
      this,
      _Visitor(this, PathUtils.getFileName(path)),
    );
  }
}

class _Visitor extends ArsyncRuleVisitor<MultiAnalysisRule> {
  final String fileName;

  _Visitor(super.rule, this.fileName);

  @override
  void visitCompilationUnit(CompilationUnit node) {

    var fileNameReported = false;
    for (final d in node.declarations.whereType<ClassDeclaration>()) {
      final name = d.className.lexeme;
      if (name.startsWith('_')) continue;

      if (!fileName.endsWith('_repository') && !fileNameReported) {
        rule.reportAtOffset(
          d.className.offset,
          d.className.length,
          diagnosticCode: RepositoryClassRestriction.fileNameCode,
        );
        fileNameReported = true;
      }
      if (!name.contains('Repository')) {
        rule.reportAtOffset(
          d.className.offset,
          d.className.length,
          diagnosticCode: RepositoryClassRestriction.classCode,
        );
      }
    }
  }
}
