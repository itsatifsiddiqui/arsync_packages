import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';

import '../ast_extensions.dart';

/// Quick fix for `scaffold_location` — replace `Scaffold` with `Container`.
class ScaffoldLocationFix extends ResolvedCorrectionProducer {
  ScaffoldLocationFix({required super.context});

  static const _fixKind = FixKind(
    'arsync.fix.scaffoldLocation',
    100,
    'Replace with Container',
  );

  @override
  FixKind? get fixKind => _fixKind;

  @override
  CorrectionApplicability get applicability =>
      CorrectionApplicability.singleLocation;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final creation = node.ancestorWidget('Scaffold');
    if (creation == null) return;
    final body = creation.namedArg('body')?.expression;

    await builder.addDartFileEdit(file, (b) {
      b.addSimpleReplacement(
        SourceRange(creation.offset, creation.length),
        body != null ? 'Container(child: ${body.toSource()})' : 'Container()',
      );
    });
  }
}
