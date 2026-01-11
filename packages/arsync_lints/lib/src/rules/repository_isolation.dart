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

    final content = context.definingUnit.content;
    final ignoreChecker = IgnoreChecker.forRule(content, name);
    if (ignoreChecker.ignoreForFile) return;

    var visitor = _Visitor(this, ignoreChecker);
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
  final IgnoreChecker ignoreChecker;

  _Visitor(this.rule, this.ignoreChecker);

  @override
  void visitImportDirective(ImportDirective node) {
    final importUri = node.uri.stringValue;
    if (importUri == null) return;
    if (ignoreChecker.shouldIgnore(node)) return;

    if (RepositoryIsolation.isBannedImport(importUri)) {
      rule.reportAtNode(node);
    }
  }
}
