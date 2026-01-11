import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';

/// Quick fix for `avoid_shrink_wrap_in_list_view` rule.
///
/// Removes the shrinkWrap: true argument from ListView.
class AvoidShrinkWrapInListViewFix extends ResolvedCorrectionProducer {
  AvoidShrinkWrapInListViewFix({required super.context});

  static const _fixKind = FixKind(
    'arsync.fix.avoidShrinkWrapInListView',
    100,
    'Remove shrinkWrap argument',
  );

  @override
  FixKind? get fixKind => _fixKind;

  @override
  CorrectionApplicability get applicability =>
      CorrectionApplicability.singleLocation;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final listView = _findListView(node);
    if (listView == null) return;

    final shrinkWrapArg = _findShrinkWrapArg(listView);
    if (shrinkWrapArg == null) return;

    // Calculate the range to delete including trailing comma/whitespace
    final content = unitResult.content;
    var endOffset = shrinkWrapArg.end;

    // Skip any trailing comma and whitespace
    while (endOffset < content.length) {
      final char = content[endOffset];
      if (char == ',') {
        endOffset++;
        // Skip whitespace after comma
        while (endOffset < content.length &&
            (content[endOffset] == ' ' ||
                content[endOffset] == '\n' ||
                content[endOffset] == '\r' ||
                content[endOffset] == '\t')) {
          endOffset++;
        }
        break;
      } else if (char == ' ' || char == '\n' || char == '\r' || char == '\t') {
        endOffset++;
      } else {
        break;
      }
    }

    await builder.addDartFileEdit(file, (builder) {
      builder.addDeletion(
        SourceRange(shrinkWrapArg.offset, endOffset - shrinkWrapArg.offset),
      );
    });
  }

  InstanceCreationExpression? _findListView(AstNode? node) {
    if (node == null) return null;

    AstNode? current = node;
    while (current != null) {
      if (current is InstanceCreationExpression) {
        final typeName = current.staticType?.getDisplayString();
        if (typeName == 'ListView') {
          return current;
        }
      }
      current = current.parent;
    }
    return null;
  }

  NamedExpression? _findShrinkWrapArg(InstanceCreationExpression node) {
    for (final arg in node.argumentList.arguments) {
      if (arg is NamedExpression && arg.name.label.name == 'shrinkWrap') {
        return arg;
      }
    }
    return null;
  }
}
