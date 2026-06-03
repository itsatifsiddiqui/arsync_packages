import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';

import 'fix_helpers.dart';

/// Quick fix for `async_viewmodel_safety` — wrap an `await` statement in
/// `try { ... } catch (e) { ref.showExceptionSheet(e); }`.
class AsyncViewModelSafetyFix extends ResolvedCorrectionProducer {
  AsyncViewModelSafetyFix({required super.context});

  static const _fixKind = FixKind(
    'arsync.fix.asyncViewModelSafety',
    100,
    'Wrap in try-catch block',
  );

  @override
  FixKind? get fixKind => _fixKind;

  @override
  CorrectionApplicability get applicability =>
      CorrectionApplicability.singleLocation;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final statement =
        node.thisOrAncestorMatching((n) => n is Statement && n is! Block)
            as Statement?;
    if (statement == null) return;

    final indent = FixHelpers.indentOf(unitResult, statement.offset);

    final tryCatch =
        '''try {
$indent  ${statement.toSource()}
$indent} catch (e) {
$indent  ref.showExceptionSheet(e);
$indent}''';

    await builder.addDartFileEdit(file, (b) {
      b.addSimpleReplacement(
        SourceRange(statement.offset, statement.length),
        tryCatch,
      );
    });
  }
}
