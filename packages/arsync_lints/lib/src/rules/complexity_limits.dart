import '../arsync_lint_rule.dart';

/// Rule D1: complexity_limits
///
/// Prevents complex, unreadable code:
/// - Max Method Parameters: 4
/// - Max Nesting Depth: 3
/// - Max Method Lines: 60
/// - Max Build Method Lines: 120
/// - Nested Ternary: Banned
class ComplexityLimits extends MultiAnalysisRule {
  ComplexityLimits()
      : super(
          name: 'complexity_limits',
          description: 'Enforce code complexity limits.',
        );

  static const paramCode = LintCode(
    'complexity_limits',
    'Methods cannot have more than 4 parameters.',
    correctionMessage:
        'Reduce parameters by using a parameter object or refactoring.',
  );

  static const nestingCode = LintCode(
    'complexity_limits',
    'Nesting depth cannot exceed 3 levels.',
    correctionMessage:
        'Refactor to reduce nesting (extract methods, early returns).',
  );

  static const methodLinesCode = LintCode(
    'complexity_limits',
    'Methods cannot exceed 60 lines.',
    correctionMessage: 'Extract logic into smaller methods or helper functions.',
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
        paramCode,
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
    if (!context.isInLibDir) {
      return;
    }

    var visitor = _Visitor(this, context);
    registry.addFunctionDeclaration(this, visitor);
    registry.addMethodDeclaration(this, visitor);
    registry.addBlock(this, visitor);
    registry.addConditionalExpression(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final MultiAnalysisRule rule;
  final RuleContext context;

  _Visitor(this.rule, this.context);

  @override
  void visitFunctionDeclaration(FunctionDeclaration node) {
    _checkParameterCount(node.functionExpression.parameters);
    _checkFunctionLines(node);
  }

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    _checkParameterCount(node.parameters);
    _checkMethodLines(node);
  }

  @override
  void visitBlock(Block node) {
    _checkNestingDepth(node);
  }

  @override
  void visitConditionalExpression(ConditionalExpression node) {
    _checkNestedTernary(node);
  }

  void _checkParameterCount(FormalParameterList? parameters) {
    if (parameters == null) return;

    final paramCount = parameters.parameters.length;
    if (paramCount > 4) {
      rule.reportAtNode(parameters, diagnosticCode: ComplexityLimits.paramCode);
    }
  }

  void _checkMethodLines(MethodDeclaration node) {
    final body = node.body;
    if (body is! BlockFunctionBody) return;

    final content = context.definingUnit.content;
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

    final content = context.definingUnit.content;
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
      if (_isNestingNode(current)) {
        depth++;
      }
      if (current is MethodDeclaration || current is FunctionDeclaration) {
        break;
      }
      current = current.parent;
    }

    if (depth > 4) {
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
      rule.reportAtNode(node, diagnosticCode: ComplexityLimits.nestedTernaryCode);
    }
  }
}
