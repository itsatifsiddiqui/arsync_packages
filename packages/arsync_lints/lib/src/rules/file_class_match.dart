import '../arsync_lint_rule.dart';

/// Rule E4: file_class_match
///
/// Enforce strict naming correspondence.
/// If file is login_screen.dart, at least one Class MUST be LoginScreen.
/// If file is auth_repository.dart, at least one Class MUST be AuthRepository.
/// Files can contain multiple classes, but at least one must match the file name.
class FileClassMatch extends AnalysisRule {
  FileClassMatch()
    : super(
        name: 'file_class_match',
        description:
            'No class in this file matches the file name. Expected a class named like the file (snake_case to PascalCase).',
      );

  static const LintCode code = LintCode(
    'file_class_match',
    'No class in this file matches the file name. Expected a class named like the file (snake_case to PascalCase).',
    correctionMessage:
        'Add or rename a class to match the file name (e.g., login_screen.dart should have LoginScreen class).',
  );

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    if (!context.isInLibDir) return;

    final path = context.definingUnit.file.path;
    if (PathUtils.isInProviders(path)) return;

    final fileName = PathUtils.getFileName(path);
    final expectedClassName = PathUtils.snakeToPascal(fileName);

    // NOTE: We pass context.allUnits to the visitor because definingUnit.content
    // only returns the LIBRARY file content, not part file (.g.dart) content.
    // The visitor must use allUnits to get the correct file's content.

    final visitor = _Visitor(this, context.allUnits, expectedClassName);
    registry.addCompilationUnit(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AnalysisRule rule;
  final List<dynamic> allUnits;
  final String expectedClassName;

  _Visitor(this.rule, this.allUnits, this.expectedClassName);

  @override
  void visitCompilationUnit(CompilationUnit node) {
    // Skip generated files and nodes with ignore comments
    if (NodeContentHelper.shouldSkipNode(node, allUnits, rule.name)) return;

    final classNames = <String>[];
    ClassDeclaration? firstClass;

    for (final declaration in node.declarations) {
      if (declaration is ClassDeclaration) {
        final className = declaration.name.lexeme;
        if (className.startsWith('_')) continue;

        classNames.add(className);
        firstClass ??= declaration;
      }
    }

    if (classNames.isEmpty) return;

    final hasMatchingClass = classNames.any(
      (name) => name == expectedClassName,
    );

    if (!hasMatchingClass && firstClass != null) {
      rule.reportAtOffset(firstClass.name.offset, firstClass.name.length);
    }
  }
}
