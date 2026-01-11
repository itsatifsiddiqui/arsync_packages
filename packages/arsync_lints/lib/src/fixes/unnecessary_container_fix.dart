import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';

/// Quick fix for `unnecessary_container` rule.
///
/// Removes the unnecessary Container and replaces it with just the child widget.
class UnnecessaryContainerFix extends ResolvedCorrectionProducer {
  UnnecessaryContainerFix({required super.context});

  static const _fixKind = FixKind(
    'arsync.fix.unnecessaryContainer',
    100,
    'Remove unnecessary Container',
  );

  @override
  FixKind? get fixKind => _fixKind;

  @override
  CorrectionApplicability get applicability =>
      CorrectionApplicability.singleLocation;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final containerWidget = _findContainerWidget(node);
    if (containerWidget == null) return;

    // Get the child argument
    final childArg = _findNamedArgument(containerWidget, 'child');
    if (childArg == null) return;

    final childSource = childArg.expression.toSource();

    await builder.addDartFileEdit(file, (builder) {
      builder.addSimpleReplacement(
        SourceRange(containerWidget.offset, containerWidget.length),
        childSource,
      );
    });
  }

  InstanceCreationExpression? _findContainerWidget(AstNode? node) {
    if (node == null) return null;

    AstNode? current = node;
    while (current != null) {
      if (current is InstanceCreationExpression) {
        final typeName = current.staticType?.getDisplayString();
        if (typeName == 'Container') {
          return current;
        }
      }
      current = current.parent;
    }
    return null;
  }

  NamedExpression? _findNamedArgument(
      InstanceCreationExpression node, String argName) {
    for (final arg in node.argumentList.arguments) {
      if (arg is NamedExpression && arg.name.label.name == argName) {
        return arg;
      }
    }
    return null;
  }
}
