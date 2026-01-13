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

    // NOTE: We pass context.allUnits to the visitor because definingUnit.content
    // only returns the LIBRARY file content, not part file (.g.dart) content.
    // The visitor must use allUnits to get the correct file's content.

    var visitor = _Visitor(this, context.allUnits);
    registry.addTryStatement(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AnalysisRule rule;
  final List<dynamic> allUnits;

  _Visitor(this.rule, this.allUnits);

  @override
  void visitTryStatement(TryStatement node) {
    // Skip generated files and nodes with ignore comments
    if (NodeContentHelper.shouldSkipNode(node, allUnits, rule.name)) return;

    rule.reportAtNode(node);
  }
}
