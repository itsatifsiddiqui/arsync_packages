import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';

/// Quick fix for `no_context_in_providers` — remove `BuildContext` parameter.
class NoContextInProvidersFix extends ResolvedCorrectionProducer {
  NoContextInProvidersFix({required super.context});

  static const _fixKind = FixKind(
    'arsync.fix.noContextInProviders',
    100,
    'Remove BuildContext parameter',
  );

  @override
  FixKind? get fixKind => _fixKind;

  @override
  CorrectionApplicability get applicability =>
      CorrectionApplicability.singleLocation;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final param = node.thisOrAncestorOfType<FormalParameter>();
    final list = param?.parent;
    if (param == null || list is! FormalParameterList) return;

    final params = list.parameters;
    final i = params.indexOf(param);
    if (i == -1) return;

    final (start, end) = switch (params.length) {
      1 => (param.offset, param.end),
      _ when i == 0 => (param.offset, params[1].offset),
      _ => (params[i - 1].end, param.end),
    };

    await builder.addDartFileEdit(file, (b) {
      b.addDeletion(SourceRange(start, end - start));
    });
  }
}
