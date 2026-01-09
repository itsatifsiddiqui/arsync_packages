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

  /// Banned import patterns for repositories.
  /// Note: riverpod is allowed because repositories must define a Provider.
  /// Note: providers/ is allowed for dependency injection (dioProvider, etc.)
  static const _bannedPatterns = [
    'screens/',
    'package:flutter_riverpod', // UI-specific riverpod
    'package:hooks_riverpod', // UI-specific hooks riverpod
  ];

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    // Only apply to files in lib/repositories/
    final path = context.definingUnit.file.path;
    if (!PathUtils.isInRepositories(path)) {
      return;
    }

    var visitor = _Visitor(this);
    registry.addImportDirective(this, visitor);
  }

  static bool isBannedImport(String importUri) {
    for (final pattern in _bannedPatterns) {
      if (importUri.contains(pattern)) {
        return true;
      }
    }
    return false;
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AnalysisRule rule;

  _Visitor(this.rule);

  @override
  void visitImportDirective(ImportDirective node) {
    final importUri = node.uri.stringValue;
    if (importUri == null) return;

    if (RepositoryIsolation.isBannedImport(importUri)) {
      rule.reportAtNode(node);
    }
  }
}
