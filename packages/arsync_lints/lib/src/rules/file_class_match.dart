import '../arsync_lint_rule.dart';

/// Rule E4: a file must contain at least one public class whose name is the
/// PascalCase version of the file name (e.g. `login_screen.dart` → `LoginScreen`).
/// Providers are exempt.
class FileClassMatch extends AnalysisRule {
  FileClassMatch() : super(name: code.lowerCaseName, description: code.problemMessage);

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

    final expected = PathUtils.snakeToPascal(PathUtils.getFileName(path));
    registry.addCompilationUnit(
      this,
      _Visitor(this, expected),
    );
  }
}

class _Visitor extends ArsyncRuleVisitor<AnalysisRule> {
  final String expectedClassName;

  _Visitor(super.rule, this.expectedClassName);

  @override
  void visitCompilationUnit(CompilationUnit node) {

    final publics = node.declarations
        .whereType<ClassDeclaration>()
        .where((d) => !d.className.lexeme.startsWith('_'))
        .toList();
    if (publics.isEmpty) return;
    if (publics.any((d) => d.className.lexeme == expectedClassName)) return;

    final first = publics.first;
    rule.reportAtOffset(first.className.offset, first.className.length);
  }
}
