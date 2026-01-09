import 'package:analyzer/source/line_info.dart';

import '../arsync_lint_rule.dart';

/// Rule C1: repository_no_try_catch
///
/// Repositories must throw errors to the ViewModel, not swallow them.
class RepositoryNoTryCatch extends AnalysisRule {
  RepositoryNoTryCatch()
      : super(
          name: 'repository_no_try_catch',
          description:
              'Repositories must throw errors, not swallow them with try/catch.',
        );

  static const LintCode code = LintCode(
    'repository_no_try_catch',
    'Repositories must throw errors, not swallow them with try/catch.',
    correctionMessage:
        'Remove the try-catch block. Let the exception bubble up to the ViewModel.',
  );

  @override
  DiagnosticCode get diagnosticCode => code;

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
    registry.addTryStatement(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AnalysisRule rule;
  final String content;
  final LineInfo lineInfo;

  _Visitor(this.rule, this.content, this.lineInfo);

  @override
  void visitTryStatement(TryStatement node) {
    if (IgnoreUtils.shouldIgnoreAtOffset(
      offset: node.offset,
      lintName: 'repository_no_try_catch',
      content: content,
      lineInfo: lineInfo,
    )) return;
    rule.reportAtNode(node);
  }
}
