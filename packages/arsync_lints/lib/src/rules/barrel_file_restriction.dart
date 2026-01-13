import '../arsync_lint_rule.dart';

/// Rule D4: barrel_file_restriction
///
/// Explicit imports are preferred to maintain layer visibility.
/// Banned in: lib/screens/, lib/features/, lib/providers/
/// Allowed in: lib/utils/, lib/widgets/, lib/models/
class BarrelFileRestriction extends AnalysisRule {
  BarrelFileRestriction()
    : super(
        name: 'barrel_file_restriction',
        description:
            'Barrel files (index.dart or export-only files) are not allowed in screens, features, or providers folders.',
      );

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
    final filePath = context.definingUnit.file.path;
    final fileName = PathUtils.getFileNameWithExtension(filePath);

    final isInBannedLocation =
        PathUtils.isInScreens(filePath) ||
        PathUtils.isInFeatures(filePath) ||
        PathUtils.isInProviders(filePath);

    if (!isInBannedLocation) return;

    // NOTE: We pass context.allUnits to the visitor because definingUnit.content
    // only returns the LIBRARY file content, not part file (.g.dart) content.
    // The visitor must use allUnits to get the correct file's content.

    final visitor = _Visitor(this, context.allUnits, fileName);
    registry.addCompilationUnit(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AnalysisRule rule;
  final List<dynamic> allUnits;
  final String fileName;

  _Visitor(this.rule, this.allUnits, this.fileName);

  @override
  void visitCompilationUnit(CompilationUnit node) {
    // Skip generated files and nodes with ignore comments
    if (NodeContentHelper.shouldSkipNode(node, allUnits, rule.name)) return;

    if (fileName == 'index.dart') {
      rule.reportAtNode(node);
      return;
    }

    final directives = node.directives;
    final declarations = node.declarations;

    if (declarations.isEmpty) {
      final hasOnlyExports = directives.every(
        (directive) =>
            directive is ExportDirective || directive is LibraryDirective,
      );
      final hasExports = directives.any(
        (directive) => directive is ExportDirective,
      );

      if (hasOnlyExports && hasExports) {
        rule.reportAtNode(node);
      }
    }
  }
}
