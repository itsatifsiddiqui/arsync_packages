import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';

import 'fix_helpers.dart';

/// Quick fix for `repository_no_try_catch` — replace `try { ... } catch ...`
/// with the try body (let the exception bubble up).
class RepositoryNoTryCatchFix extends ResolvedCorrectionProducer {
  RepositoryNoTryCatchFix({required super.context});

  static const _fixKind = FixKind(
    'arsync.fix.repositoryNoTryCatch',
    100,
    'Remove try-catch block (keep try body)',
  );

  @override
  FixKind? get fixKind => _fixKind;

  @override
  CorrectionApplicability get applicability =>
      CorrectionApplicability.singleLocation;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final tryStmt = node.thisOrAncestorOfType<TryStatement>();
    if (tryStmt == null || tryStmt.body.statements.isEmpty) return;

    final indent = FixHelpers.indentOf(unitResult, tryStmt.offset);
    final body = tryStmt.body.statements
        .map((s) => '$indent${s.toSource()}')
        .join('\n');

    await builder.addDartFileEdit(file, (b) {
      b.addSimpleReplacement(
        SourceRange(tryStmt.offset, tryStmt.length),
        body,
      );
    });
  }
}
