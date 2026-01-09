import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../utils.dart';

/// Rule: repository_provider_declaration
///
/// Repository files must define a provider at the top level.
/// The provider name must end with "RepoProvider".
///
/// Good: final authRepoProvider = Provider((ref) => AuthRepository());
/// Bad: No provider defined, or provider named "authProvider"
class RepositoryProviderDeclaration extends DartLintRule {
  const RepositoryProviderDeclaration() : super(code: _missingProviderCode);

  static const _missingProviderCode = LintCode(
    name: 'repository_provider_declaration',
    problemMessage:
        'Repository file must define a provider ending with "RepoProvider".',
    correctionMessage:
        'Add a provider like: final authRepoProvider = Provider((ref) => AuthRepository());',
  );

  static const _wrongNamingCode = LintCode(
    name: 'repository_provider_declaration',
    problemMessage: 'Repository provider name must end with "RepoProvider".',
    correctionMessage:
        'Rename the provider to end with "RepoProvider" (e.g., authRepoProvider).',
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    // Only apply to files in repositories directory
    if (!PathUtils.isInRepositories(resolver.path)) {
      return;
    }

    final fileName = PathUtils.getFileName(resolver.path);

    // Skip if file doesn't end with _repository
    if (!fileName.endsWith('_repository')) {
      return;
    }

    // Track provider declarations
    final providerDeclarations = <VariableDeclaration>[];
    CompilationUnit? compilationUnit;

    context.registry.addCompilationUnit((node) {
      compilationUnit = node;
    });

    context.registry.addTopLevelVariableDeclaration((node) {
      for (final variable in node.variables.variables) {
        final initializer = variable.initializer;
        if (initializer == null) continue;

        // Check if this is a Provider declaration
        final source = initializer.toSource();
        if (source.startsWith('Provider')) {
          providerDeclarations.add(variable);
        }
      }
    });

    // After collecting all providers, validate
    context.addPostRunCallback(() {
      if (compilationUnit == null) return;

      // Check if any RepoProvider exists
      final hasRepoProvider = providerDeclarations.any(
        (decl) => decl.name.lexeme.endsWith('RepoProvider'),
      );

      if (providerDeclarations.isEmpty) {
        // No provider at all - report on the file (first declaration)
        final firstDecl = compilationUnit!.declarations.firstOrNull;
        if (firstDecl != null) {
          reporter.atNode(firstDecl, _missingProviderCode);
        }
      } else if (!hasRepoProvider) {
        // Has providers but none end with RepoProvider
        for (final decl in providerDeclarations) {
          reporter.atToken(decl.name, _wrongNamingCode);
        }
      }
    });
  }
}
