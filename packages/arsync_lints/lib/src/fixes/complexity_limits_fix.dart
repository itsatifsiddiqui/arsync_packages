import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';

/// Quick fix for `complexity_limits` rule - add TODO for refactoring.
///
/// For complex issues like too many parameters, nesting depth, or method length,
/// we add a TODO comment as a placeholder since auto-refactoring is complex.
class ComplexityLimitsAddTodoFix extends ResolvedCorrectionProducer {
  ComplexityLimitsAddTodoFix({required super.context});

  static const _fixKind = FixKind(
    'arsync.fix.complexityLimitsAddTodo',
    100,
    'Add TODO to refactor for complexity',
  );

  @override
  FixKind? get fixKind => _fixKind;

  @override
  CorrectionApplicability get applicability =>
      CorrectionApplicability.singleLocation;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    // Determine what kind of complexity issue this is
    String todoMessage;

    if (node is FormalParameterList) {
      todoMessage =
          'TODO: Reduce parameters (max 4) - consider using a parameter object using records';
    } else if (node is Block) {
      todoMessage =
          'TODO: Reduce nesting depth (max 3) - extract methods or use early returns';
    } else if (node is MethodDeclaration || node is FunctionDeclaration) {
      final name = node is MethodDeclaration
          ? (node as MethodDeclaration).name.lexeme
          : (node as FunctionDeclaration).name.lexeme;
      if (name == 'build') {
        todoMessage =
            'TODO: Reduce build() method length (max 120 lines) - extract widgets';
      } else {
        todoMessage =
            'TODO: Reduce method length (max 60 lines) - extract helper methods';
      }
    } else if (node is SimpleIdentifier) {
      // Could be method name from reportAtOffset
      todoMessage = 'TODO: Reduce method complexity - extract helper methods';
    } else if (node is ConditionalExpression) {
      todoMessage =
          'TODO: Replace nested ternary with if-else or switch expression';
    } else {
      todoMessage = 'TODO: Refactor to reduce complexity';
    }

    await builder.addDartFileEdit(file, (builder) {
      builder.addSimpleInsertion(node.offset, '// $todoMessage\n');
    });
  }
}
