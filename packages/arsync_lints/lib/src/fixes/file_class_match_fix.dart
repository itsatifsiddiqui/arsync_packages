import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import "../ast_extensions.dart";
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';

import '../utils.dart';

/// Quick fix for `file_class_match` — rename class to match the file name.
class FileClassMatchFix extends ResolvedCorrectionProducer {
  FileClassMatchFix({required super.context});

  static const _fixKind = FixKind(
    'arsync.fix.fileClassMatch',
    100,
    'Rename class to match file name',
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

    final expected = PathUtils.snakeToPascal(
      PathUtils.getFileName(unitResult.path),
    );

    await builder.addDartFileEdit(file, (b) {
      b.addSimpleReplacement(SourceRange(name.offset, name.length), expected);
    });
  }
}
