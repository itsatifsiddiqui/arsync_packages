import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';

/// Quick fix for `provider_state_class` rule - add @freezed annotation.
class ProviderStateClassAddFreezedFix extends ResolvedCorrectionProducer {
  ProviderStateClassAddFreezedFix({required super.context});

  static const _fixKind = FixKind(
    'arsync.fix.providerStateClassAddFreezed',
    100,
    'Add @freezed annotation',
  );

  @override
  FixKind? get fixKind => _fixKind;

  @override
  CorrectionApplicability get applicability =>
      CorrectionApplicability.singleLocation;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final classDecl = node.thisOrAncestorOfType<ClassDeclaration>();
    if (classDecl == null) return;

    final hasFreezed = classDecl.metadata.any(
      (a) => a.name.name == 'freezed' || a.name.name == 'Freezed',
    );
    if (hasFreezed) return;

    await builder.addDartFileEdit(file, (b) {
      b.addSimpleInsertion(classDecl.offset, '@freezed\n');
    });
  }
}
