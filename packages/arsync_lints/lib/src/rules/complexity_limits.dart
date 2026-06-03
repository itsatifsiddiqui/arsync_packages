import '../arsync_lint_rule.dart';

/// Rule D1: complexity_limits
///
/// Max nesting depth 5, max method 60 lines, max build() 120 lines, no nested
/// ternaries.
class ComplexityLimits extends MultiAnalysisRule {
  ComplexityLimits()
    : super(
        name: 'complexity_limits',
        description: 'Enforce code complexity limits.',
      );

  static const nestingCode = LintCode(
    'complexity_limits',
    'Nesting depth cannot exceed 5 levels.',
    correctionMessage:
        'Refactor to reduce nesting (extract methods, early returns).',
  );

  static const methodLinesCode = LintCode(
    'complexity_limits',
    'Methods cannot exceed 60 lines.',
    correctionMessage:
        'Extract logic into smaller methods or helper functions.',
  );

  static const buildLinesCode = LintCode(
    'complexity_limits',
    'build() method cannot exceed 120 lines.',
    correctionMessage: 'Extract widgets into separate methods or widgets.',
  );

  static const nestedTernaryCode = LintCode(
    'complexity_limits',
    'Nested ternary operators are banned.',
    correctionMessage: 'Use if-else statements or switch expressions instead.',
  );

  @override
  List<DiagnosticCode> get diagnosticCodes => [
    nestingCode,
    methodLinesCode,
    buildLinesCode,
    nestedTernaryCode,
  ];

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    if (!context.isInLibDir) return;

    final visitor = _Visitor(this, context);
    registry.addFunctionDeclaration(this, visitor);
    registry.addMethodDeclaration(this, visitor);
    registry.addBlock(this, visitor);
    registry.addConditionalExpression(this, visitor);
  }
}

class _Visitor extends ArsyncRuleVisitor<MultiAnalysisRule> {
  _Visitor(super.rule, this.context);

  final RuleContext context;

  @override
  void visitFunctionDeclaration(FunctionDeclaration node) {
    _checkLines(
      node.functionExpression.body,
      nameOffset: node.name.offset,
      nameLength: node.name.length,
      isBuild: false,
    );
  }

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    _checkLines(
      node.body,
      nameOffset: node.name.offset,
      nameLength: node.name.length,
      isBuild: node.name.lexeme == 'build',
    );
  }

  @override
  void visitBlock(Block node) {
    var depth = 0;
    for (AstNode? c = node.parent; c != null; c = c.parent) {
      if (_isNestingNode(c)) depth++;
      if (c is MethodDeclaration || c is FunctionDeclaration) break;
    }
    if (depth > 5) {
      rule.reportAtNode(node, diagnosticCode: ComplexityLimits.nestingCode);
    }
  }

  @override
  void visitConditionalExpression(ConditionalExpression node) {
    if (node.thenExpression is ConditionalExpression ||
        node.elseExpression is ConditionalExpression) {
      rule.reportAtNode(
        node,
        diagnosticCode: ComplexityLimits.nestedTernaryCode,
      );
    }
  }

  void _checkLines(
    FunctionBody body, {
    required int nameOffset,
    required int nameLength,
    required bool isBuild,
  }) {
    if (body is! BlockFunctionBody) return;
    final content = context.currentUnit?.content;
    if (content == null) return;

    final lines = _countLines(content, body.offset, body.end);
    final limit = isBuild ? 120 : 60;
    if (lines <= limit) return;

    rule.reportAtOffset(
      nameOffset,
      nameLength,
      diagnosticCode: isBuild
          ? ComplexityLimits.buildLinesCode
          : ComplexityLimits.methodLinesCode,
    );
  }

  static int _countLines(String content, int start, int end) {
    var count = 1;
    final limit = end < content.length ? end : content.length;
    for (var i = start; i < limit; i++) {
      if (content[i] == '\n') count++;
    }
    return count;
  }

  static bool _isNestingNode(AstNode node) {
    if (node is IfStatement ||
        node is ForStatement ||
        node is WhileStatement ||
        node is DoStatement ||
        node is SwitchStatement ||
        node is TryStatement) {
      return true;
    }
    // Count blocks only if they're closures, not method/function bodies.
    if (node is Block) {
      final parent = node.parent;
      if (parent is FunctionExpression) {
        final grandparent = parent.parent;
        return grandparent is! MethodDeclaration &&
            grandparent is! FunctionDeclaration;
      }
    }
    return false;
  }
}
