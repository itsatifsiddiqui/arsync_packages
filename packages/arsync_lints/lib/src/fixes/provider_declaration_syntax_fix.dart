import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';

/// Quick fix for `provider_declaration_syntax` rule.
///
/// Converts bad provider declarations to use .new constructor syntax:
/// - Before: `NotifierProvider<MyNotifier, State>(() => MyNotifier())`
/// - After: `NotifierProvider.autoDispose(MyNotifier.new)`
class ProviderDeclarationSyntaxFix extends ResolvedCorrectionProducer {
  ProviderDeclarationSyntaxFix({required super.context});

  static const _fixKind = FixKind(
    'arsync.fix.providerDeclarationSyntax',
    1000, // Very high priority to appear before ignore options
    'Use .new constructor syntax',
  );

  @override
  FixKind? get fixKind => _fixKind;

  @override
  CorrectionApplicability get applicability =>
      CorrectionApplicability.automatically;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    // Find the expression that was flagged (the provider initializer)
    final targetNode = _findProviderExpression(node);
    if (targetNode == null) return;

    final source = targetNode.toSource();

    // Extract provider type (NotifierProvider, AsyncNotifierProvider, etc.)
    final providerType = _extractProviderType(source);
    if (providerType == null) return;

    // Extract the Notifier class name
    final notifierClassName = _extractNotifierClassName(targetNode, source);
    if (notifierClassName == null) return;

    // Check if it already has autoDispose
    final hasAutoDispose = source.contains('.autoDispose');

    // Build the corrected syntax
    final correctedSyntax = hasAutoDispose
        ? '$providerType.autoDispose($notifierClassName.new)'
        : '$providerType.autoDispose($notifierClassName.new)';

    await builder.addDartFileEdit(file, (builder) {
      builder.addSimpleReplacement(
        SourceRange(targetNode.offset, targetNode.length),
        correctedSyntax,
      );
    });
  }

  /// Find the provider expression from the diagnostic node
  AstNode? _findProviderExpression(AstNode? node) {
    if (node == null) return null;

    // The node might be the expression itself or we need to traverse up
    AstNode? current = node;
    while (current != null) {
      if (current is MethodInvocation ||
          current is InstanceCreationExpression) {
        final source = current.toSource();
        if (_isProviderExpression(source)) {
          return current;
        }
      }
      if (current is FunctionExpressionInvocation) {
        final source = current.toSource();
        if (_isProviderExpression(source)) {
          return current;
        }
      }
      // Check if current node's source starts with a provider type
      final source = current.toSource();
      if (_isProviderExpression(source)) {
        return current;
      }
      current = current.parent;
    }
    return node;
  }

  bool _isProviderExpression(String source) {
    return source.startsWith('NotifierProvider') ||
        source.startsWith('AsyncNotifierProvider') ||
        source.startsWith('StreamNotifierProvider');
  }

  /// Extract the provider type from the source
  String? _extractProviderType(String source) {
    if (source.startsWith('AsyncNotifierProvider')) {
      return 'AsyncNotifierProvider';
    }
    if (source.startsWith('StreamNotifierProvider')) {
      return 'StreamNotifierProvider';
    }
    if (source.startsWith('NotifierProvider')) {
      return 'NotifierProvider';
    }
    return null;
  }

  /// Extract the Notifier class name from the expression
  String? _extractNotifierClassName(AstNode node, String source) {
    // Try to extract from type arguments first
    // Pattern: NotifierProvider<ClassName, StateType>(...)
    final typeArgMatch = RegExp(r'<(\w+),\s*\w+>').firstMatch(source);
    if (typeArgMatch != null) {
      return typeArgMatch.group(1);
    }

    // Try to extract from closure body
    // Pattern: () => ClassName() or () { return ClassName(); }
    final closureMatch = RegExp(
      r'\(\)\s*(?:=>|{\s*return)\s*(\w+)\(\)',
    ).firstMatch(source);
    if (closureMatch != null) {
      return closureMatch.group(1);
    }

    // Try to extract from simple instantiation
    // Pattern: (() => ClassName())
    final simpleMatch = RegExp(r'(\w+)\(\)(?:\s*;|\s*\})').firstMatch(source);
    if (simpleMatch != null) {
      return simpleMatch.group(1);
    }

    return null;
  }
}
