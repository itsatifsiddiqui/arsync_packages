import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';

/// Quick fix for `prefer_space_between_elements` rule.
///
/// Adds a blank line before the reported element.
class PreferSpaceBetweenElementsFix extends ResolvedCorrectionProducer {
  PreferSpaceBetweenElementsFix({required super.context});

  static const _fixKind = FixKind(
    'arsync.fix.preferSpaceBetweenElements',
    100,
    'Add blank line before element',
  );

  @override
  FixKind? get fixKind => _fixKind;

  @override
  CorrectionApplicability get applicability =>
      CorrectionApplicability.singleLocation;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final targetNode = _findTargetNode(node);
    if (targetNode == null) return;

    final lineInfo = unitResult.lineInfo;
    final startLine = lineInfo.getLocation(targetNode.offset).lineNumber - 1;
    final lineStart = lineInfo.getOffsetOfLine(startLine);

    await builder.addDartFileEdit(file, (builder) {
      // Insert a blank line before the element
      builder.addSimpleInsertion(lineStart, '\n');
    });
  }

  AstNode? _findTargetNode(AstNode? node) {
    if (node == null) return null;

    AstNode? current = node;
    while (current != null) {
      if (current is ConstructorDeclaration ||
          current is MethodDeclaration ||
          current is FieldDeclaration) {
        return current;
      }
      current = current.parent;
    }
    return null;
  }
}
