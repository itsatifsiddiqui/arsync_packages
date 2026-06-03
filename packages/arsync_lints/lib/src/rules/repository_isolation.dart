import '../arsync_lint_rule.dart';

/// Rule A4: files in `lib/repositories/` cannot import UI or ViewModel layers.
class RepositoryIsolation extends AnalysisRule {
  RepositoryIsolation() : super(name: code.lowerCaseName, description: code.problemMessage);

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
    if (!PathUtils.isInRepositories(context.definingUnit.file.path)) return;
    registry.addImportDirective(
      this,
      BannedImportVisitor(
        this, _bannedPatterns, reportAtNode),
    );
  }

  static bool isBannedImport(String uri) => _bannedPatterns.any(uri.contains);
}
