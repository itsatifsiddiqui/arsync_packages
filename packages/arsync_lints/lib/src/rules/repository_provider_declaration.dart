import '../arsync_lint_rule.dart';

/// Rule: repository_provider_declaration
///
/// Repository files must define a provider at the top level.
/// The provider name must end with "RepoProvider".
///
/// Good: final authRepoProvider = Provider((ref) => AuthRepository());
/// Bad: No provider defined, or provider named "authProvider"
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
  List<DiagnosticCode> get diagnosticCodes =>
      [missingProviderCode, wrongNamingCode];

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

    // Skip if file doesn't end with _repository
    if (!fileName.endsWith('_repository')) {
      return;
    }

    final visitor = _Visitor(this);
    registry.addCompilationUnit(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final MultiAnalysisRule rule;

  _Visitor(this.rule);

  @override
  void visitCompilationUnit(CompilationUnit node) {
    // Track provider declarations
    final providerDeclarations = <VariableDeclaration>[];

    for (final declaration in node.declarations) {
      if (declaration is TopLevelVariableDeclaration) {
        for (final variable in declaration.variables.variables) {
          final initializer = variable.initializer;
          if (initializer == null) continue;

          // Check if this is a Provider declaration
          final source = initializer.toSource();
          if (source.startsWith('Provider')) {
            providerDeclarations.add(variable);
          }
        }
      }
    }

    // Check if any RepoProvider exists
    final hasRepoProvider = providerDeclarations.any(
      (decl) => decl.name.lexeme.endsWith('RepoProvider'),
    );

    if (providerDeclarations.isEmpty) {
      // No provider at all - report on the file (first declaration)
      final firstDecl = node.declarations.firstOrNull;
      if (firstDecl != null) {
        rule.reportAtNode(
            firstDecl, diagnosticCode: RepositoryProviderDeclaration.missingProviderCode);
      }
    } else if (!hasRepoProvider) {
      // Has providers but none end with RepoProvider
      for (final decl in providerDeclarations) {
        rule.reportAtOffset(
          decl.name.offset,
          decl.name.length,
          diagnosticCode: RepositoryProviderDeclaration.wrongNamingCode,
        );
      }
    }
  }
}
