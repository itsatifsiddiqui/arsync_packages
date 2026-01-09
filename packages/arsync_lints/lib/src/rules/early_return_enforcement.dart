import 'package:analyzer/source/line_info.dart';

import '../arsync_lint_rule.dart';

/// Rule D6: early_return_enforcement
///
/// Enforces early return pattern to reduce nesting and ensure all code paths
/// are properly handled.
///
/// Bad:
/// ```dart
/// void process() {
///   if (isValid) {
///     doSomething();
///     doMore();
///   }
/// }
/// ```
///
/// Good:
/// ```dart
/// void process() {
///   if (!isValid) return;
///   doSomething();
///   doMore();
/// }
/// ```
///
/// This rule detects:
/// - If statements without else that wrap significant logic
/// - Suggests inverting the condition and using early return
class EarlyReturnEnforcement extends AnalysisRule {
  EarlyReturnEnforcement()
      : super(
          name: 'early_return_enforcement',
          description:
              'Prefer early returns over wrapping code in if blocks without else.',
        );

  static const LintCode code = LintCode(
    'early_return_enforcement',
    'Consider using early return instead of wrapping code in if block.',
    correctionMessage:
        'Invert the condition and return/throw early, then place the main logic outside the if block.',
  );

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    if (!context.isInLibDir) {
      return;
    }

    final content = context.definingUnit.content;
    final lineInfo = LineInfo.fromContent(content);

    final visitor = _Visitor(this, content, lineInfo);
    registry.addIfStatement(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AnalysisRule rule;
  final String content;
  final LineInfo lineInfo;

  _Visitor(this.rule, this.content, this.lineInfo);

  @override
  void visitIfStatement(IfStatement node) {
    // Skip if there's an else clause - already handling both paths
    if (node.elseStatement != null) return;

    // Skip if inside a loop (might need continue, not return)
    if (_isInsideLoop(node)) return;

    // Get the then statement
    final thenStatement = node.thenStatement;

    // Only check block statements
    if (thenStatement is! Block) return;

    // Skip empty or trivial blocks
    final statements = thenStatement.statements;
    if (statements.isEmpty) return;

    // Skip if the block only contains a single return/throw - that's already early return style
    if (statements.length == 1) {
      final single = statements.first;
      if (single is ReturnStatement) return;
      if (single is ExpressionStatement && single.expression is ThrowExpression) {
        return;
      }
    }

    // Check if this is a significant if block (2+ statements or nested blocks)
    final hasSignificantContent = _hasSignificantContent(thenStatement);
    if (!hasSignificantContent) return;

    // Check if this if statement is at the beginning of a method/function body
    // (i.e., the main logic is wrapped in the if)
    if (_isWrappingMainLogic(node)) {
      if (IgnoreUtils.shouldIgnoreAtOffset(
        offset: node.ifKeyword.offset,
        lintName: 'early_return_enforcement',
        content: content,
        lineInfo: lineInfo,
      )) {
        return;
      }
      rule.reportAtOffset(node.ifKeyword.offset, node.ifKeyword.length);
    }
  }

  bool _isInsideLoop(AstNode node) {
    AstNode? current = node.parent;
    while (current != null) {
      if (current is ForStatement ||
          current is WhileStatement ||
          current is DoStatement ||
          current is ForEachParts) {
        return true;
      }
      if (current is FunctionBody || current is MethodDeclaration) {
        break;
      }
      current = current.parent;
    }
    return false;
  }

  bool _hasSignificantContent(Block block) {
    final statements = block.statements;

    // 2+ statements is significant
    if (statements.length >= 2) return true;

    // Single statement that is itself a block or if
    if (statements.length == 1) {
      final single = statements.first;
      if (single is Block || single is IfStatement) return true;

      // Expression statement with method invocation chain
      if (single is ExpressionStatement) {
        final expr = single.expression;
        if (expr is MethodInvocation || expr is CascadeExpression) {
          return true;
        }
      }
    }

    return false;
  }

  bool _isWrappingMainLogic(IfStatement node) {
    // Get the parent block
    final parent = node.parent;
    if (parent is! Block) return false;

    final siblings = parent.statements;

    // If this is the only statement (or one of first few), it's likely wrapping main logic
    final index = siblings.indexOf(node);
    if (index == -1) return false;

    // Check if this if statement is early in the method and takes up most of the logic
    // Allow some variable declarations before the if
    int significantStatementsBefore = 0;
    for (int i = 0; i < index; i++) {
      final stmt = siblings[i];
      if (stmt is! VariableDeclarationStatement &&
          stmt is! ExpressionStatement) {
        significantStatementsBefore++;
      }
    }

    // Check if there are significant statements after the if
    int significantStatementsAfter = 0;
    for (int i = index + 1; i < siblings.length; i++) {
      final stmt = siblings[i];
      if (stmt is! ReturnStatement || (stmt.expression != null)) {
        significantStatementsAfter++;
      }
    }

    // Report if:
    // - Few statements before the if (0-2 variable declarations are OK)
    // - Few or no statements after the if (empty return is OK)
    // - The if block has significant content
    return significantStatementsBefore <= 2 && significantStatementsAfter <= 1;
  }
}
