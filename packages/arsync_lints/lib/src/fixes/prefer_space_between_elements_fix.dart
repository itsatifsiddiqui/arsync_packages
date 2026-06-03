import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';

/// Quick fix for `prefer_space_between_elements` — add blank line before element.
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
    final target = node.thisOrAncestorMatching(
      (n) =>
          n is ConstructorDeclaration ||
          n is MethodDeclaration ||
          n is FieldDeclaration,
    );
    if (target == null) return;

    final lineInfo = unitResult.lineInfo;
    final line = lineInfo.getLocation(target.offset).lineNumber - 1;

    await builder.addDartFileEdit(file, (b) {
      b.addSimpleInsertion(lineInfo.getOffsetOfLine(line), '\n');
    });
  }
}
