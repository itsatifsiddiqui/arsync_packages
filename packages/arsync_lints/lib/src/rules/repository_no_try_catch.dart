import '../arsync_lint_rule.dart';

/// Rule C1: repositories must let exceptions bubble up to the ViewModel layer
/// rather than swallowing them in `try`/`catch`.
class RepositoryNoTryCatch extends AnalysisRule {
  RepositoryNoTryCatch() : super(name: code.lowerCaseName, description: code.problemMessage);

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
    if (!PathUtils.isInRepositories(context.definingUnit.file.path)) return;
    registry.addTryStatement(this, _Visitor(this));
  }
}

class _Visitor extends ArsyncRuleVisitor<AnalysisRule> {
  _Visitor(super.rule);

  @override
  void visitTryStatement(TryStatement node) {
    rule.reportAtNode(node);
  }
}
