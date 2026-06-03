import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';

import '../ast_extensions.dart';

/// Quick fix for `unnecessary_container` — unwrap `Container(child: x)` to `x`.
class UnnecessaryContainerFix extends ResolvedCorrectionProducer {
  UnnecessaryContainerFix({required super.context});

  static const _fixKind = FixKind(
    'arsync.fix.unnecessaryContainer',
    100,
    'Remove unnecessary Container',
  );

  @override
  FixKind? get fixKind => _fixKind;

  @override
  CorrectionApplicability get applicability =>
      CorrectionApplicability.singleLocation;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final container = node.ancestorWidget('Container');
    final child = container?.namedArg('child');
    if (container == null || child == null) return;

    await builder.addDartFileEdit(file, (b) {
      b.addSimpleReplacement(
        SourceRange(container.offset, container.length),
        child.expression.toSource(),
      );
    });
  }
}
