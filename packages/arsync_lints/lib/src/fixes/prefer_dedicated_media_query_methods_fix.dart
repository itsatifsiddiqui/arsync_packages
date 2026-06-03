import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';

/// Quick fix for `prefer_dedicated_media_query_methods` —
/// `MediaQuery.of(context).x` → `MediaQuery.xOf(context)`.
class PreferDedicatedMediaQueryMethodsFix extends ResolvedCorrectionProducer {
  PreferDedicatedMediaQueryMethodsFix({required super.context});

  static const _fixKind = FixKind(
    'arsync.fix.preferDedicatedMediaQueryMethods',
    100,
    'Use dedicated MediaQuery method',
  );

  @override
  FixKind? get fixKind => _fixKind;

  @override
  CorrectionApplicability get applicability =>
      CorrectionApplicability.singleLocation;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    // MediaQuery.sizeOf(context).width|height
    final access = node.thisOrAncestorOfType<PropertyAccess>();
    if (access != null) {
      final target = access.target;
      if (target is MethodInvocation && target.methodName.name == 'sizeOf') {
        final replacement = switch (access.propertyName.name) {
          'width' => 'MediaQuery.widthOf${target.argumentList.toSource()}',
          'height' => 'MediaQuery.heightOf${target.argumentList.toSource()}',
          _ => null,
        };
        if (replacement == null) return;
        await builder.addDartFileEdit(file, (b) {
          b.addSimpleReplacement(
            SourceRange(access.offset, access.length),
            replacement,
          );
        });
        return;
      }
    }

    // MediaQuery.of|maybeOf(context) → MediaQuery.sizeOf(context)
    final call = node.thisOrAncestorMatching((n) {
      if (n is! MethodInvocation) return false;
      return n.target?.toString() == 'MediaQuery' &&
          (n.methodName.name == 'of' || n.methodName.name == 'maybeOf');
    }) as MethodInvocation?;
    if (call == null) return;

    await builder.addDartFileEdit(file, (b) {
      b.addSimpleReplacement(
        SourceRange(call.offset, call.length),
        'MediaQuery.sizeOf${call.argumentList.toSource()}',
      );
    });
  }
}
