import '../arsync_lint_rule.dart';

/// Rule B4: async_viewmodel_safety
///
/// Async operations in ViewModels must handle errors explicitly.
class AsyncViewModelSafety extends AnalysisRule {
  AsyncViewModelSafety()
      : super(
          name: 'async_viewmodel_safety',
          description:
              'Async operations in ViewModels must be wrapped in try/catch.',
        );

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
    final path = context.definingUnit.file.path;
    if (!PathUtils.isInProviders(path)) {
      return;
    }

    final visitor = _Visitor(this);
    registry.addClassDeclaration(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AnalysisRule rule;

  _Visitor(this.rule);

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    final extendsClause = node.extendsClause;
    if (extendsClause == null) return;

    final superclassName = extendsClause.superclass.name.lexeme;

    // Only check Notifier and AsyncNotifier classes
    if (!superclassName.contains('Notifier') &&
        !superclassName.contains('AsyncNotifier')) {
      return;
    }

    // Check all methods in the class
    for (final member in node.members) {
      if (member is MethodDeclaration) {
        _checkMethod(member);
      }
    }
  }

  void _checkMethod(MethodDeclaration method) {
    final body = method.body;
    if (body is! BlockFunctionBody) return;

    // Check if method contains await expressions
    final awaitVisitor = _AwaitExpressionVisitor();
    body.accept(awaitVisitor);

    for (final awaitExpr in awaitVisitor.awaitExpressions) {
      // Check if this await is inside a try block
      if (!_isInsideTryBlock(awaitExpr)) {
        rule.reportAtNode(awaitExpr);
      }
    }
  }

  bool _isInsideTryBlock(AstNode node) {
    AstNode? current = node.parent;
    while (current != null) {
      if (current is TryStatement) {
        return true;
      }
      // Stop at method boundary
      if (current is MethodDeclaration || current is FunctionDeclaration) {
        break;
      }
      current = current.parent;
    }
    return false;
  }
}

class _AwaitExpressionVisitor extends RecursiveAstVisitor<void> {
  final List<AwaitExpression> awaitExpressions = [];

  @override
  void visitAwaitExpression(AwaitExpression node) {
    awaitExpressions.add(node);
    super.visitAwaitExpression(node);
  }
}
