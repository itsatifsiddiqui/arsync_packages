import 'package:analyzer/source/line_info.dart';

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
    'widgets/',
    'views/',
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

    final content = context.definingUnit.content;
    final lineInfo = LineInfo.fromContent(content);

    var visitor = _Visitor(this, content, lineInfo);
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
  final String content;
  final LineInfo lineInfo;

  _Visitor(this.rule, this.content, this.lineInfo);

  @override
  void visitImportDirective(ImportDirective node) {
    final importUri = node.uri.stringValue;
    if (importUri == null) return;

    if (RepositoryIsolation.isBannedImport(importUri)) {
      if (IgnoreUtils.shouldIgnoreAtOffset(
        offset: node.offset,
        lintName: 'repository_isolation',
        content: content,
        lineInfo: lineInfo,
      )) {
        return;
      }
      rule.reportAtNode(node);
    }
  }
}
