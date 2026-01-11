import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';

/// Quick fix for `unsafe_null_assertion` rule.
///
/// Replaces force null assertion `!` with an if-null operator `??`.
class UnsafeNullAssertionFix extends ResolvedCorrectionProducer {
  UnsafeNullAssertionFix({required super.context});

  static const _fixKind = FixKind(
    'arsync.fix.unsafeNullAssertion',
    100,
    'Replace with if-null operator (??)',
  );

  @override
  FixKind? get fixKind => _fixKind;

  @override
  CorrectionApplicability get applicability =>
      CorrectionApplicability.singleLocation;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final postfixExpression = _findPostfixExpression(node);
    if (postfixExpression == null) return;

    final operand = postfixExpression.operand;
    final operandSource = operand.toSource();

    await builder.addDartFileEdit(file, (builder) {
      builder.addSimpleReplacement(
        SourceRange(postfixExpression.offset, postfixExpression.length),
        '$operandSource ?? /* default value */',
      );
    });
  }

  PostfixExpression? _findPostfixExpression(AstNode? node) {
    if (node == null) return null;

    AstNode? current = node;
    while (current != null) {
      if (current is PostfixExpression) {
        return current;
      }
      current = current.parent;
    }
    return null;
  }
}
