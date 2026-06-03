import '../arsync_lint_rule.dart';

/// Rule D4: `index.dart` and other export-only files are banned inside
/// `lib/screens/`, `lib/features/`, and `lib/providers/` — they hide the layer
/// boundaries that explicit imports keep visible.
class BarrelFileRestriction extends AnalysisRule {
  BarrelFileRestriction() : super(name: code.lowerCaseName, description: code.problemMessage);

  static const LintCode code = LintCode(
    'barrel_file_restriction',
    'Barrel files (index.dart or export-only files) are not allowed in screens, features, or providers folders.',
    correctionMessage: 'Use explicit imports instead of barrel files.',
  );

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    final path = context.definingUnit.file.path;
    final banned =
        PathUtils.isInScreens(path) ||
        PathUtils.isInFeatures(path) ||
        PathUtils.isInProviders(path);
    if (!banned) return;

    registry.addCompilationUnit(
      this,
      _Visitor(this, PathUtils.getFileNameWithExtension(path)),
    );
  }
}

class _Visitor extends ArsyncRuleVisitor<AnalysisRule> {
  final String fileName;

  _Visitor(super.rule, this.fileName);

  @override
  void visitCompilationUnit(CompilationUnit node) {

    if (fileName == 'index.dart') {
      rule.reportAtNode(node);
      return;
    }

    if (node.declarations.isNotEmpty) return;
    final hasExports = node.directives.any((d) => d is ExportDirective);
    final onlyExportsOrLib = node.directives.every(
      (d) => d is ExportDirective || d is LibraryDirective,
    );
    if (hasExports && onlyExportsOrLib) rule.reportAtNode(node);
  }
}
