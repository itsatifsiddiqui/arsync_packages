import '../arsync_lint_rule.dart';

/// Rule: a `*_repository.dart` file must declare a top-level provider whose
/// name ends with `RepoProvider`.
class RepositoryProviderDeclaration extends MultiAnalysisRule {
  RepositoryProviderDeclaration()
    : super(
        name: 'repository_provider_declaration',
        description:
            'Repository file must define a provider ending with "RepoProvider".',
      );

  static const missingProviderCode = LintCode(
    'repository_provider_declaration',
    'Repository file must define a provider ending with "RepoProvider".',
    correctionMessage:
        'Add a provider like: final authRepoProvider = Provider((ref) => AuthRepository());',
  );

  static const wrongNamingCode = LintCode(
    'repository_provider_declaration',
    'Repository provider name must end with "RepoProvider".',
    correctionMessage:
        'Rename the provider to end with "RepoProvider" (e.g., authRepoProvider).',
  );

  @override
  List<DiagnosticCode> get diagnosticCodes => [
    missingProviderCode,
    wrongNamingCode,
  ];

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    final path = context.definingUnit.file.path;
    if (!PathUtils.isInRepositories(path)) return;
    if (!PathUtils.getFileName(path).endsWith('_repository')) return;
    registry.addCompilationUnit(this, _Visitor(this));
  }
}

class _Visitor extends ArsyncRuleVisitor<MultiAnalysisRule> {
  _Visitor(super.rule);

  @override
  void visitCompilationUnit(CompilationUnit node) {

    final providers = [
      for (final d in node.declarations.whereType<TopLevelVariableDeclaration>())
        for (final v in d.variables.variables)
          if (_isProviderCall(v.initializer)) v,
    ];

    if (providers.isEmpty) {
      final first = node.declarations.firstOrNull;
      if (first != null) {
        rule.reportAtNode(
          first,
          diagnosticCode: RepositoryProviderDeclaration.missingProviderCode,
        );
      }
      return;
    }

    if (providers.any((p) => p.name.lexeme.endsWith('RepoProvider'))) return;
    for (final p in providers) {
      rule.reportAtOffset(
        p.name.offset,
        p.name.length,
        diagnosticCode: RepositoryProviderDeclaration.wrongNamingCode,
      );
    }
  }

  /// True if [initializer] is a constructor call whose type name starts with
  /// `Provider` (matches `Provider`, `ProviderFamily`, etc.).
  static bool _isProviderCall(Expression? initializer) {
    if (initializer is! InstanceCreationExpression) return false;
    return initializer.typeName.startsWith('Provider');
  }
}
