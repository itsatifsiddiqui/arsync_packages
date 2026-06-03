import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';

/// Quick fix for `provider_autodispose_enforcement` — insert `.autoDispose`
/// into a provider initializer.
class ProviderAutodisposeEnforcementFix extends ResolvedCorrectionProducer {
  ProviderAutodisposeEnforcementFix({required super.context});

  static const _fixKind = FixKind(
    'arsync.fix.providerAutodisposeEnforcement',
    100,
    'Add .autoDispose to provider',
  );

  @override
  FixKind? get fixKind => _fixKind;

  @override
  CorrectionApplicability get applicability =>
      CorrectionApplicability.singleLocation;

  static const _providerTypes = [
    'Provider',
    'NotifierProvider',
    'AsyncNotifierProvider',
    'StreamNotifierProvider',
    'StateProvider',
    'StateNotifierProvider',
    'FutureProvider',
    'StreamProvider',
  ];

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final initializer =
        node.thisOrAncestorOfType<VariableDeclaration>()?.initializer;
    if (initializer == null) return;

    final source = initializer.toSource();
    if (source.contains('.autoDispose')) return;

    for (final type in _providerTypes) {
      if (!source.startsWith(type)) continue;
      final after = source.substring(type.length);
      if (after.startsWith('<') ||
          after.startsWith('(') ||
          after.startsWith('.family')) {
        await builder.addDartFileEdit(file, (b) {
          b.addSimpleInsertion(initializer.offset + type.length, '.autoDispose');
        });
        return;
      }
    }
  }
}
