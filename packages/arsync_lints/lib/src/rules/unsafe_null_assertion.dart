import 'package:analyzer/dart/ast/token.dart';

import '../arsync_lint_rule.dart';

/// A lint rule that discourages the use of force null assertion (`!` operator).
///
/// Using `!` can lead to runtime exceptions if the value is null. Prefer using
/// the if-null operator (`??`), null-aware operator (`?.`), or pattern matching
/// for safer null handling.
///
/// ### Example
///
/// #### BAD:
/// ```dart
/// final value = someValue!; // LINT
/// final name = user!.name; // LINT
/// ```
///
/// #### GOOD:
/// ```dart
/// final value = someValue ?? defaultValue;
/// final name = user?.name ?? 'Unknown';
/// if (user case User(:final name)) { ... }
/// ```
class UnsafeNullAssertion extends AnalysisRule {
  UnsafeNullAssertion()
    : super(name: code.name, description: code.problemMessage);

  static const code = LintCode(
    'unsafe_null_assertion',
    'Avoid using the force null assertion (!) operator.',
    correctionMessage:
        'Prefer using the if-null operator (??), null-aware operator (?.), '
        'or pattern matching instead of force casting with !.',
  );

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    // NOTE: We pass context.allUnits to the visitor because definingUnit.content
    // only returns the LIBRARY file content, not part file (.g.dart) content.
    // The visitor must use allUnits to get the correct file's content.

    final visitor = _Visitor(this, context.allUnits);
    registry.addPostfixExpression(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  _Visitor(this.rule, this.allUnits);

  final AnalysisRule rule;
  final List<dynamic> allUnits;

  @override
  void visitPostfixExpression(PostfixExpression node) {
    // Skip generated files and nodes with ignore comments
    if (NodeContentHelper.shouldSkipNode(node, allUnits, rule.name)) return;

    // Check if the operator is the null assertion operator (!)
    if (node.operator.type == TokenType.BANG) {
      rule.reportAtNode(node);
    }
  }
}
