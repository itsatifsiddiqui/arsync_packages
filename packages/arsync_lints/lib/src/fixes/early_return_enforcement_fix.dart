import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';

/// Quick fix for `early_return_enforcement` rule.
///
/// Converts:
/// ```dart
/// if (condition) {
///   doSomething();
/// }
/// ```
///
/// To:
/// ```dart
/// if (!condition) return;
/// doSomething();
/// ```
class EarlyReturnEnforcementFix extends ResolvedCorrectionProducer {
  EarlyReturnEnforcementFix({required super.context});

  static const _fixKind = FixKind(
    'arsync.fix.earlyReturnEnforcement',
    100,
    'Convert to early return pattern',
  );

  @override
  FixKind? get fixKind => _fixKind;

  @override
  CorrectionApplicability get applicability =>
      CorrectionApplicability.singleLocation;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final ifStatement = _findIfStatement(node);
    if (ifStatement == null) return;

    // Don't fix if there's an else clause
    if (ifStatement.elseStatement != null) return;

    final thenStatement = ifStatement.thenStatement;
    if (thenStatement is! Block) return;

    // Get the condition and invert it
    final condition = ifStatement.expression;
    final invertedCondition = _invertCondition(condition);

    // Get the body statements
    final bodyStatements = thenStatement.statements;
    if (bodyStatements.isEmpty) return;

    // Get indentation
    final lineInfo = unitResult.lineInfo;
    final ifLine = lineInfo.getLocation(ifStatement.offset).lineNumber - 1;
    final lineStart = lineInfo.getOffsetOfLine(ifLine);
    final content = unitResult.content;

    var indent = '';
    for (var i = lineStart; i < ifStatement.offset; i++) {
      final char = content[i];
      if (char == ' ' || char == '\t') {
        indent += char;
      } else {
        break;
      }
    }

    // Build the replacement code
    final buffer = StringBuffer();

    // Add early return
    buffer.write('if ($invertedCondition) return;\n');

    // Add the body statements at the same indentation level
    for (final stmt in bodyStatements) {
      buffer.write('$indent${stmt.toSource()}\n');
    }

    // Remove trailing newline since the original had one
    var replacement = buffer.toString();
    if (replacement.endsWith('\n')) {
      replacement = replacement.substring(0, replacement.length - 1);
    }

    await builder.addDartFileEdit(file, (builder) {
      builder.addSimpleReplacement(
        SourceRange(ifStatement.offset, ifStatement.length),
        replacement,
      );
    });
  }

  String _invertCondition(Expression condition) {
    final source = condition.toSource();

    // Handle already negated conditions
    if (condition is PrefixExpression && condition.operator.lexeme == '!') {
      // !condition -> condition
      final operand = condition.operand;
      if (operand is ParenthesizedExpression) {
        return operand.expression.toSource();
      }
      return operand.toSource();
    }

    // Handle comparison operators
    if (condition is BinaryExpression) {
      final left = condition.leftOperand.toSource();
      final right = condition.rightOperand.toSource();
      final op = condition.operator.lexeme;

      switch (op) {
        case '==':
          return '$left != $right';
        case '!=':
          return '$left == $right';
        case '>':
          return '$left <= $right';
        case '<':
          return '$left >= $right';
        case '>=':
          return '$left < $right';
        case '<=':
          return '$left > $right';
        case '&&':
          // De Morgan's law: !(a && b) = !a || !b
          // But simpler to just wrap in !()
          return '!($source)';
        case '||':
          // De Morgan's law: !(a || b) = !a && !b
          // But simpler to just wrap in !()
          return '!($source)';
      }
    }

    // Handle 'is' and 'is!'
    if (condition is IsExpression) {
      final expr = condition.expression.toSource();
      final type = condition.type.toSource();
      if (condition.notOperator != null) {
        // is! -> is
        return '$expr is $type';
      } else {
        // is -> is!
        return '$expr is! $type';
      }
    }

    // Default: wrap in !()
    if (condition is ParenthesizedExpression) {
      return '!$source';
    }
    return '!($source)';
  }

  IfStatement? _findIfStatement(AstNode? node) {
    if (node == null) return null;
    if (node is IfStatement) return node;

    // Check if we're on the 'if' keyword
    AstNode? current = node;
    while (current != null) {
      if (current is IfStatement) return current;
      current = current.parent;
    }
    return null;
  }
}
