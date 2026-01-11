import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';

/// Quick fix for `avoid_consecutive_sliver_to_box_adapter` rule.
///
/// Adds a TODO comment suggesting to use SliverList.list instead.
class AvoidConsecutiveSliverToBoxAdapterFix extends ResolvedCorrectionProducer {
  AvoidConsecutiveSliverToBoxAdapterFix({required super.context});

  static const _fixKind = FixKind(
    'arsync.fix.avoidConsecutiveSliverToBoxAdapter',
    100,
    'Add TODO: Use SliverList.list instead',
  );

  @override
  FixKind? get fixKind => _fixKind;

  @override
  CorrectionApplicability get applicability =>
      CorrectionApplicability.singleLocation;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final listLiteral = _findListLiteral(node);
    if (listLiteral == null) return;

    final lineInfo = unitResult.lineInfo;
    final startLine = lineInfo.getLocation(listLiteral.offset).lineNumber - 1;
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
        '$indent// TODO: Replace consecutive SliverToBoxAdapter with SliverList.list\n',
      );
    });
  }

  ListLiteral? _findListLiteral(AstNode? node) {
    if (node == null) return null;
    if (node is ListLiteral) return node;

    AstNode? current = node;
    while (current != null) {
      if (current is ListLiteral) return current;
      current = current.parent;
    }
    return null;
  }
}
