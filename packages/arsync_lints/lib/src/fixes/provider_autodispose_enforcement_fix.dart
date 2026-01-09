import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';

/// Quick fix for `provider_autodispose_enforcement` rule.
///
/// Adds .autoDispose to provider declarations:
/// - Before: `NotifierProvider(AuthNotifier.new)`
/// - After: `NotifierProvider.autoDispose(AuthNotifier.new)`
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
    final initializer = _findInitializer(node);
    if (initializer == null) return;

    final source = initializer.toSource();

    // Already has autoDispose
    if (source.contains('.autoDispose')) return;

    // Find the provider type and add .autoDispose
    for (final providerType in _providerTypes) {
      if (source.startsWith(providerType)) {
        // Check if it's ProviderType< or ProviderType( or ProviderType.family
        final afterType = source.substring(providerType.length);
        if (afterType.startsWith('<') ||
            afterType.startsWith('(') ||
            afterType.startsWith('.family')) {
          // Insert .autoDispose after the provider type
          final insertPosition = initializer.offset + providerType.length;

          await builder.addDartFileEdit(file, (builder) {
            builder.addSimpleInsertion(insertPosition, '.autoDispose');
          });
          return;
        }
      }
    }
  }

  Expression? _findInitializer(AstNode? node) {
    if (node == null) return null;

    // If we're at an identifier (the variable name), get the parent
    if (node is SimpleIdentifier) {
      final parent = node.parent;
      if (parent is VariableDeclaration) {
        return parent.initializer;
      }
    }

    if (node is VariableDeclaration) {
      return node.initializer;
    }

    AstNode? current = node;
    while (current != null) {
      if (current is VariableDeclaration) {
        return current.initializer;
      }
      current = current.parent;
    }
    return null;
  }
}
