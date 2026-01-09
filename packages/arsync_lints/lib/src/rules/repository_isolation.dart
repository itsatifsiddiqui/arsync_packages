import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../utils.dart';

/// Rule A4: repository_isolation
///
/// Repositories handle data fetching only. They cannot manage state or UI.
class RepositoryIsolation extends DartLintRule {
  const RepositoryIsolation() : super(code: _code);

  static const _code = LintCode(
    name: 'repository_isolation',
    problemMessage: 'Repositories cannot depend on UI or ViewModels.',
    correctionMessage:
        'Remove the import. Repositories should only handle data fetching.',
  );

  /// Banned import patterns for repositories.
  /// Note: riverpod is allowed because repositories must define a Provider.
  /// Note: providers/ is allowed for dependency injection (dioProvider, etc.)
  static const _bannedPatterns = [
    'screens/',
    'package:flutter_riverpod', // UI-specific riverpod
    'package:hooks_riverpod', // UI-specific hooks riverpod
  ];

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    // Only apply to files in lib/repositories/
    if (!PathUtils.isInRepositories(resolver.path)) {
      return;
    }

    context.registry.addImportDirective((node) {
      final importUri = node.uri.stringValue;
      if (importUri == null) return;

      if (_isBannedImport(importUri)) {
        reporter.atNode(node, _code);
      }
    });
  }

  bool _isBannedImport(String importUri) {
    for (final pattern in _bannedPatterns) {
      if (importUri.contains(pattern)) {
        return true;
      }
    }
    return false;
  }
}
