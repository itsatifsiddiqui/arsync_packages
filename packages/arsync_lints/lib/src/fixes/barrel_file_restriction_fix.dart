import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';

/// Quick fix for `barrel_file_restriction` rule - add TODO to remove barrel file.
///
/// Since we can't automatically delete files or convert barrel files,
/// we add a TODO comment as a placeholder.
class BarrelFileRestrictionFix extends ResolvedCorrectionProducer {
  BarrelFileRestrictionFix({required super.context});

  static const _fixKind = FixKind(
    'arsync.fix.barrelFileRestriction',
    100,
    'Add TODO to remove barrel file',
  );

  @override
  FixKind? get fixKind => _fixKind;

  @override
  CorrectionApplicability get applicability =>
      CorrectionApplicability.singleLocation;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final unit = _findCompilationUnit(node);
    if (unit == null) return;

    final todoComment = '''// TODO: Remove this barrel file.
// Barrel files (index.dart or export-only files) are not allowed in
// screens, features, or providers folders.
// Use explicit imports instead of re-exporting from a single file.

''';

    await builder.addDartFileEdit(file, (builder) {
      builder.addSimpleInsertion(0, todoComment);
    });
  }

  CompilationUnit? _findCompilationUnit(AstNode? node) {
    if (node == null) return null;
    if (node is CompilationUnit) return node;

    AstNode? current = node;
    while (current != null) {
      if (current is CompilationUnit) return current;
      current = current.parent;
    }
    return null;
  }
}
