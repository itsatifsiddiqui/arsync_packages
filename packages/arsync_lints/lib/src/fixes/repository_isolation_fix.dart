import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';

import 'fix_helpers.dart';

/// Quick fix for `repository_isolation` rule - remove banned import.
class RepositoryIsolationFix extends ResolvedCorrectionProducer {
  RepositoryIsolationFix({required super.context});

  static const _fixKind = FixKind(
    'arsync.fix.repositoryIsolation',
    100,
    'Remove banned import',
  );

  @override
  FixKind? get fixKind => _fixKind;

  @override
  CorrectionApplicability get applicability =>
      CorrectionApplicability.singleLocation;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final import = node.thisOrAncestorOfType<ImportDirective>();
    if (import == null) return;
    await FixHelpers.deleteLine(builder, unitResult, file, import);
  }
}
