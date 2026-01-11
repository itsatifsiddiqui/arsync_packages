import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';

/// Quick fix for `avoid_single_child` rule.
///
/// Adds a TODO comment suggesting to use a single-child widget or add more children.
class AvoidSingleChildFix extends ResolvedCorrectionProducer {
  AvoidSingleChildFix({required super.context});

  static const _fixKind = FixKind(
    'arsync.fix.avoidSingleChild',
    100,
    'Add TODO: Use single-child widget',
  );

  @override
  FixKind? get fixKind => _fixKind;

  @override
  CorrectionApplicability get applicability =>
      CorrectionApplicability.singleLocation;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final widgetNode = _findMultiChildWidget(node);
    if (widgetNode == null) return;

    final lineInfo = unitResult.lineInfo;
    final startLine = lineInfo.getLocation(widgetNode.offset).lineNumber - 1;
    final lineStart = lineInfo.getOffsetOfLine(startLine);

    // Get indentation
    final content = unitResult.content;
    var indent = '';
    var i = lineStart;
    while (i < content.length && (content[i] == ' ' || content[i] == '\t')) {
      indent += content[i];
      i++;
    }

    await builder.addDartFileEdit(file, (builder) {
      builder.addSimpleInsertion(
        lineStart,
        '$indent// TODO: Consider using a single-child widget (e.g., Center, Align) or add more children\n',
      );
    });
  }

  InstanceCreationExpression? _findMultiChildWidget(AstNode? node) {
    if (node == null) return null;

    AstNode? current = node;
    while (current != null) {
      if (current is InstanceCreationExpression) {
        final typeName = current.staticType?.getDisplayString();
        if (_isMultiChildWidget(typeName)) {
          return current;
        }
      }
      current = current.parent;
    }
    return null;
  }

  bool _isMultiChildWidget(String? typeName) {
    return const [
      'Column',
      'Row',
      'Flex',
      'Wrap',
      'Stack',
      'ListView',
      'SliverList',
      'SliverMainAxisGroup',
      'SliverCrossAxisGroup',
    ].contains(typeName);
  }
}
