import '../arsync_lint_rule.dart';

/// Rule D1: complexity_limits
///
/// Prevents complex, unreadable code:
/// - Max Nesting Depth: 5
/// - Max Method Lines: 60
/// - Max Build Method Lines: 120
/// - Nested Ternary: Banned
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

    // NOTE: We pass context.allUnits to the visitor because definingUnit.content
    // only returns the LIBRARY file content, not part file (.g.dart) content.
    final visitor = _Visitor(this, context.allUnits);
    registry.addFunctionDeclaration(this, visitor);
    registry.addMethodDeclaration(this, visitor);
    registry.addBlock(this, visitor);
    registry.addConditionalExpression(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final MultiAnalysisRule rule;
  final List<dynamic> allUnits;

  _Visitor(this.rule, this.allUnits);

  @override
  void visitFunctionDeclaration(FunctionDeclaration node) {
    // Skip generated files and nodes with ignore comments
    if (NodeContentHelper.shouldSkipNode(node, allUnits, rule.name)) return;
    _checkFunctionLines(node);
  }

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    // Skip generated files and nodes with ignore comments
    if (NodeContentHelper.shouldSkipNode(node, allUnits, rule.name)) return;
    _checkMethodLines(node);
  }

  @override
  void visitBlock(Block node) {
    // Skip generated files and nodes with ignore comments
    if (NodeContentHelper.shouldSkipNode(node, allUnits, rule.name)) return;
    _checkNestingDepth(node);
  }

  @override
  void visitConditionalExpression(ConditionalExpression node) {
    // Skip generated files and nodes with ignore comments
    if (NodeContentHelper.shouldSkipNode(node, allUnits, rule.name)) return;
    _checkNestedTernary(node);
  }

  void _checkMethodLines(MethodDeclaration node) {
    final body = node.body;
    if (body is! BlockFunctionBody) return;

    // Get the correct content for this node's file
    final content = NodeContentHelper.getContentForNode(node, allUnits);
    if (content == null) return;

    final startLine = _countLines(content, 0, body.offset);
    final endLine = _countLines(content, 0, body.end);
    final lineCount = endLine - startLine + 1;

    final isBuildMethod = node.name.lexeme == 'build';

    if (isBuildMethod) {
      if (lineCount > 120) {
        rule.reportAtOffset(
          node.name.offset,
          node.name.length,
          diagnosticCode: ComplexityLimits.buildLinesCode,
        );
      }
    } else {
      if (lineCount > 60) {
        rule.reportAtOffset(
          node.name.offset,
          node.name.length,
          diagnosticCode: ComplexityLimits.methodLinesCode,
        );
      }
    }
  }

  void _checkFunctionLines(FunctionDeclaration node) {
    final body = node.functionExpression.body;
    if (body is! BlockFunctionBody) return;

    // Get the correct content for this node's file
    final content = NodeContentHelper.getContentForNode(node, allUnits);
    if (content == null) return;

    final startLine = _countLines(content, 0, body.offset);
    final endLine = _countLines(content, 0, body.end);
    final lineCount = endLine - startLine + 1;

    if (lineCount > 60) {
      rule.reportAtOffset(
        node.name.offset,
        node.name.length,
        diagnosticCode: ComplexityLimits.methodLinesCode,
      );
    }
  }

  int _countLines(String content, int start, int end) {
    int count = 1;
    for (int i = start; i < end && i < content.length; i++) {
      if (content[i] == '\n') count++;
    }
    return count;
  }

  void _checkNestingDepth(Block node) {
    int depth = 0;
    AstNode? current = node;

    while (current != null) {
      if (_isNestingNode(current)) depth++;
      if (current is MethodDeclaration || current is FunctionDeclaration) break;
      current = current.parent;
    }

    if (depth > 5) {
      rule.reportAtNode(node, diagnosticCode: ComplexityLimits.nestingCode);
    }
  }

  bool _isNestingNode(AstNode node) {
    return node is Block ||
        node is IfStatement ||
        node is ForStatement ||
        node is WhileStatement ||
        node is DoStatement ||
        node is SwitchStatement ||
        node is TryStatement;
  }

  void _checkNestedTernary(ConditionalExpression node) {
    if (node.thenExpression is ConditionalExpression ||
        node.elseExpression is ConditionalExpression) {
      rule.reportAtNode(
        node,
        diagnosticCode: ComplexityLimits.nestedTernaryCode,
      );
    }
  }
}
