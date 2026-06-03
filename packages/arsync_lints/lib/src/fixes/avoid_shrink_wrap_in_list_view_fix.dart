import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';

/// Quick fix for `avoid_shrink_wrap_in_list_view` — remove `shrinkWrap` arg.
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
    final listView = node.thisOrAncestorMatching(
          (n) =>
              n is InstanceCreationExpression &&
              n.staticType?.getDisplayString() == 'ListView',
        )
        as InstanceCreationExpression?;
    if (listView == null) return;

    final arg = listView.argumentList.arguments
        .whereType<NamedExpression>()
        .where((e) => e.name.label.name == 'shrinkWrap')
        .firstOrNull;
    if (arg == null) return;

    // Extend deletion through trailing comma + whitespace.
    final content = unitResult.content;
    var end = arg.end;
    while (end < content.length) {
      final c = content[end];
      if (c == ',') {
        end++;
        while (end < content.length && _isWhitespace(content[end])) {
          end++;
        }
        break;
      }
      if (!_isWhitespace(c)) break;
      end++;
    }

    await builder.addDartFileEdit(file, (b) {
      b.addDeletion(SourceRange(arg.offset, end - arg.offset));
    });
  }

  static bool _isWhitespace(String c) =>
      c == ' ' || c == '\n' || c == '\r' || c == '\t';
}
