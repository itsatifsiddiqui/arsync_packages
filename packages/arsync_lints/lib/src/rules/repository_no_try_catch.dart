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
    final path = context.definingUnit.file.path;
    if (!PathUtils.isInRepositories(path)) return;

    final content = context.definingUnit.content;
    final ignoreChecker = IgnoreChecker.forRule(content, name);
    if (ignoreChecker.ignoreForFile) return;

    var visitor = _Visitor(this, ignoreChecker);
    registry.addTryStatement(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AnalysisRule rule;
  final IgnoreChecker ignoreChecker;

  _Visitor(this.rule, this.ignoreChecker);

  @override
  void visitTryStatement(TryStatement node) {
    if (ignoreChecker.shouldIgnore(node)) return;

    rule.reportAtNode(node);
  }
}
