import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import "../ast_extensions.dart";
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';

/// Quick fix for `prefer_to_include_sliver_in_name` — prefix class name with "Sliver".
class PreferToIncludeSliverInNameFix extends ResolvedCorrectionProducer {
  PreferToIncludeSliverInNameFix({required super.context});

  static const _fixKind = FixKind(
    'arsync.fix.preferToIncludeSliverInName',
    100,
    'Add "Sliver" prefix to class name',
  );

  @override
  FixKind? get fixKind => _fixKind;

  @override
  CorrectionApplicability get applicability =>
      CorrectionApplicability.singleLocation;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final name = node.thisOrAncestorOfType<ClassDeclaration>()?.className;
    if (name == null) return;

    await builder.addDartFileEdit(file, (b) {
      b.addSimpleReplacement(
        SourceRange(name.offset, name.length),
        'Sliver${name.lexeme}',
      );
    });
  }
}
