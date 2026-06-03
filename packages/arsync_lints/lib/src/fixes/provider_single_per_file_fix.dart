import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';

import '../utils.dart';

/// Quick fix for `provider_single_per_file` — rename provider to match file.
class ProviderSinglePerFileRenameFix extends ResolvedCorrectionProducer {
  ProviderSinglePerFileRenameFix({required super.context});

  static const _fixKind = FixKind(
    'arsync.fix.providerSinglePerFileRename',
    100,
    'Rename provider to match file name',
  );

  @override
  FixKind? get fixKind => _fixKind;

  @override
  CorrectionApplicability get applicability =>
      CorrectionApplicability.singleLocation;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final name = node.thisOrAncestorOfType<VariableDeclaration>()?.name;
    if (name == null) return;

    final fileName = PathUtils.getFileName(unitResult.path);
    if (!fileName.endsWith('_provider')) return;

    final expected =
        '${PathUtils.snakeToCamel(fileName.replaceAll('_provider', ''))}Provider';

    await builder.addDartFileEdit(file, (b) {
      b.addSimpleReplacement(SourceRange(name.offset, name.length), expected);
    });
  }
}
