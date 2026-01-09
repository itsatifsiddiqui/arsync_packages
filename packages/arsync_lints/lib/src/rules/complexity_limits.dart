import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../utils.dart';

/// Rule D1: complexity_limits
///
/// Prevents complex, unreadable code:
/// - Max Method Parameters: 4
/// - Max Nesting Depth: 3
/// - Max Method Lines: 60
/// - Max Build Method Lines: 120
/// - Nested Ternary: Banned
class ComplexityLimits extends DartLintRule {
  const ComplexityLimits() : super(code: _paramCode);

  static const _paramCode = LintCode(
    name: 'complexity_limits',
    problemMessage: 'Methods cannot have more than 4 parameters.',
    correctionMessage:
        'Reduce parameters by using a parameter object or refactoring.',
  );

  static const _nestingCode = LintCode(
    name: 'complexity_limits',
    problemMessage: 'Nesting depth cannot exceed 3 levels.',
    correctionMessage:
        'Refactor to reduce nesting (extract methods, early returns).',
  );

  static const _methodLinesCode = LintCode(
    name: 'complexity_limits',
    problemMessage: 'Methods cannot exceed 60 lines.',
    correctionMessage: 'Extract logic into smaller methods or helper functions.',
  );

  static const _buildLinesCode = LintCode(
    name: 'complexity_limits',
    problemMessage: 'build() method cannot exceed 120 lines.',
    correctionMessage: 'Extract widgets into separate methods or widgets.',
  );

  static const _nestedTernaryCode = LintCode(
    name: 'complexity_limits',
    problemMessage: 'Nested ternary operators are banned.',
    correctionMessage: 'Use if-else statements or switch expressions instead.',
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    // Only apply to lib/ files
    if (!PathUtils.isInLib(resolver.path)) {
      return;
    }

    // Check method parameters and line count (functions)
    context.registry.addFunctionDeclaration((node) {
      _checkParameterCount(node.functionExpression.parameters, reporter);
      _checkFunctionLines(node, reporter, resolver);
    });

    // Check method parameters and line count (methods)
    context.registry.addMethodDeclaration((node) {
      _checkParameterCount(node.parameters, reporter);
      _checkMethodLines(node, reporter, resolver);
    });

    // Check nesting depth
    context.registry.addBlock((node) {
      _checkNestingDepth(node, reporter);
    });

    // Check for nested ternaries
    context.registry.addConditionalExpression((node) {
      _checkNestedTernary(node, reporter);
    });
  }

  void _checkParameterCount(
      FormalParameterList? parameters, ErrorReporter reporter) {
    if (parameters == null) return;

    final paramCount = parameters.parameters.length;
    if (paramCount > 4) {
      reporter.atNode(parameters, _paramCode);
    }
  }

  void _checkMethodLines(
    MethodDeclaration node,
    ErrorReporter reporter,
    CustomLintResolver resolver,
  ) {
    final body = node.body;
    if (body is! BlockFunctionBody) return;

    final startLine = resolver.lineInfo.getLocation(body.offset).lineNumber;
    final endLine = resolver.lineInfo.getLocation(body.end).lineNumber;
    final lineCount = endLine - startLine + 1;

    final isBuildMethod = node.name.lexeme == 'build';

    // build() has a higher limit (120 lines)
    if (isBuildMethod) {
      if (lineCount > 120) {
        reporter.atToken(node.name, _buildLinesCode);
      }
    } else {
      // All other methods: 60 lines max
      if (lineCount > 60) {
        reporter.atToken(node.name, _methodLinesCode);
      }
    }
  }

  void _checkFunctionLines(
    FunctionDeclaration node,
    ErrorReporter reporter,
    CustomLintResolver resolver,
  ) {
    final body = node.functionExpression.body;
    if (body is! BlockFunctionBody) return;

    final startLine = resolver.lineInfo.getLocation(body.offset).lineNumber;
    final endLine = resolver.lineInfo.getLocation(body.end).lineNumber;
    final lineCount = endLine - startLine + 1;

    // Functions: 60 lines max
    if (lineCount > 60) {
      reporter.atToken(node.name, _methodLinesCode);
    }
  }

  void _checkNestingDepth(Block node, ErrorReporter reporter) {
    int depth = 0;
    AstNode? current = node;

    while (current != null) {
      if (_isNestingNode(current)) {
        depth++;
      }
      // Stop at method/function boundary
      if (current is MethodDeclaration || current is FunctionDeclaration) {
        break;
      }
      current = current.parent;
    }

    // depth > 4 means > 3 nested blocks (method body + 3 levels)
    if (depth > 4) {
      reporter.atNode(node, _nestingCode);
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

  void _checkNestedTernary(ConditionalExpression node, ErrorReporter reporter) {
    // Check if then or else branches contain another ternary
    if (node.thenExpression is ConditionalExpression ||
        node.elseExpression is ConditionalExpression) {
      reporter.atNode(node, _nestedTernaryCode);
    }
  }
}
