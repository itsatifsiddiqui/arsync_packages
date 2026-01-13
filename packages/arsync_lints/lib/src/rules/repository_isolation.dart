import '../arsync_lint_rule.dart';

/// Rule A4: repository_isolation
///
/// Repositories handle data fetching only. They cannot manage state or UI.
class RepositoryIsolation extends AnalysisRule {
  RepositoryIsolation()
    : super(
        name: 'repository_isolation',
        description: 'Repositories cannot depend on UI or ViewModels.',
      );

  static const LintCode code = LintCode(
    'repository_isolation',
    'Repositories cannot depend on UI or ViewModels.',
    correctionMessage:
        'Remove the import. Repositories should only handle data fetching.',
  );

  @override
  DiagnosticCode get diagnosticCode => code;

  static const _bannedPatterns = ['screens/', 'widgets/', 'views/'];

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    final path = context.definingUnit.file.path;
    if (!PathUtils.isInRepositories(path)) return;

    // NOTE: We pass context.allUnits to the visitor because definingUnit.content
    // only returns the LIBRARY file content, not part file (.g.dart) content.
    // The visitor must use allUnits to get the correct file's content.

    var visitor = _Visitor(this, context.allUnits);
    registry.addImportDirective(this, visitor);
  }

  static bool isBannedImport(String importUri) {
    for (final pattern in _bannedPatterns) {
      if (importUri.contains(pattern)) return true;
    }
    return false;
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AnalysisRule rule;
  final List<dynamic> allUnits;

  _Visitor(this.rule, this.allUnits);

  @override
  void visitImportDirective(ImportDirective node) {
    // Skip generated files and nodes with ignore comments
    if (NodeContentHelper.shouldSkipNode(node, allUnits, rule.name)) return;

    final importUri = node.uri.stringValue;
    if (importUri == null) return;

    if (RepositoryIsolation.isBannedImport(importUri)) {
      rule.reportAtNode(node);
    }
  }
}
