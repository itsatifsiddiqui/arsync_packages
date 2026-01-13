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
    if (!PathUtils.isInProviders(path)) return;

    // NOTE: We pass context.allUnits to the visitor because definingUnit.content
    // only returns the LIBRARY file content, not part file (.g.dart) content.
    // The visitor must use allUnits to get the correct file's content.

    final visitor = _Visitor(this, context.allUnits);
    registry.addClassDeclaration(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AnalysisRule rule;
  final List<dynamic> allUnits;

  _Visitor(this.rule, this.allUnits);

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    // Skip generated files and nodes with ignore comments
    if (NodeContentHelper.shouldSkipNode(node, allUnits, rule.name)) return;

    final extendsClause = node.extendsClause;
    if (extendsClause == null) return;

    final superclassName = extendsClause.superclass.name.lexeme;
    if (!superclassName.contains('Notifier') &&
        !superclassName.contains('AsyncNotifier')) {
      return;
    }

    for (final member in node.members) {
      if (member is MethodDeclaration) {
        _checkMethod(member);
      }
    }
  }

  void _checkMethod(MethodDeclaration method) {
    final body = method.body;
    if (body is! BlockFunctionBody) return;

    final awaitVisitor = _AwaitExpressionVisitor();
    body.accept(awaitVisitor);

    for (final awaitExpr in awaitVisitor.awaitExpressions) {
      if (NodeContentHelper.shouldSkipNode(awaitExpr, allUnits, rule.name)) {
        continue;
      }
      if (!_isInsideTryBlock(awaitExpr)) {
        rule.reportAtNode(awaitExpr);
      }
    }
  }

  bool _isInsideTryBlock(AstNode node) {
    AstNode? current = node.parent;
    while (current != null) {
      if (current is TryStatement) return true;
      if (current is MethodDeclaration || current is FunctionDeclaration) break;
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
