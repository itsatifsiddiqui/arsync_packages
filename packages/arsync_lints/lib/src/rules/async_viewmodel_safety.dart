import '../arsync_lint_rule.dart';

/// Rule B4: an `await` inside a `Notifier`/`AsyncNotifier` method in
/// `lib/providers/` must be wrapped in `try`/`catch`. `await persist(...)`
/// (and `await persist(...).future`) are exempt — they are offline-cache
/// helpers that handle their own errors.
class AsyncViewModelSafety extends AnalysisRule {
  AsyncViewModelSafety() : super(name: code.lowerCaseName, description: code.problemMessage);

  static const LintCode code = LintCode(
    'async_viewmodel_safety',
    'Async operations in ViewModels must be wrapped in try/catch.',
    correctionMessage: 'Add a try/catch block around the await call.',
  );

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    if (!PathUtils.isInProviders(context.definingUnit.file.path)) return;
    registry.addAwaitExpression(this, _Visitor(this));
  }
}

class _Visitor extends ArsyncRuleVisitor<AnalysisRule> {
  _Visitor(super.rule);

  @override
  void visitAwaitExpression(AwaitExpression node) {

    final method = node.thisOrAncestorOfType<MethodDeclaration>();
    if (method == null || method.body is! BlockFunctionBody) return;

    final classDecl = method.thisOrAncestorOfType<ClassDeclaration>();
    if (classDecl == null || !classDecl.extendsNotifierVariant) return;

    if (_isPersistCall(node.expression)) return;
    if (_isInsideTryBlock(node)) return;
    rule.reportAtNode(node);
  }

  static bool _isPersistCall(Expression e) {
    if (e is MethodInvocation) return e.methodName.name == 'persist';
    if (e is PropertyAccess) {
      final t = e.target;
      return t is MethodInvocation && t.methodName.name == 'persist';
    }
    return false;
  }

  static bool _isInsideTryBlock(AstNode node) {
    for (AstNode? c = node.parent; c != null; c = c.parent) {
      if (c is TryStatement) return true;
      if (c is MethodDeclaration || c is FunctionDeclaration) return false;
    }
    return false;
  }
}
