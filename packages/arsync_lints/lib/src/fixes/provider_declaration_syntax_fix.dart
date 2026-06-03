import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';

/// Quick fix for `provider_declaration_syntax` — convert provider declaration
/// to `.autoDispose(MyNotifier.new)` syntax.
class ProviderDeclarationSyntaxFix extends ResolvedCorrectionProducer {
  ProviderDeclarationSyntaxFix({required super.context});

  static const _fixKind = FixKind(
    'arsync.fix.providerDeclarationSyntax',
    1000,
    'Use .new constructor syntax',
  );

  static const _providerTypes = [
    'AsyncNotifierProvider',
    'StreamNotifierProvider',
    'NotifierProvider',
  ];

  @override
  FixKind? get fixKind => _fixKind;

  @override
  CorrectionApplicability get applicability =>
      CorrectionApplicability.automatically;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final target = node.thisOrAncestorMatching(
      (n) =>
          _providerTypeFor(n.toSource()) != null &&
          (n is MethodInvocation ||
              n is InstanceCreationExpression ||
              n is FunctionExpressionInvocation),
    );
    if (target == null) return;

    final source = target.toSource();
    final providerType = _providerTypeFor(source);
    final notifier = _extractNotifierClassName(source);
    if (providerType == null || notifier == null) return;

    await builder.addDartFileEdit(file, (b) {
      b.addSimpleReplacement(
        SourceRange(target.offset, target.length),
        '$providerType.autoDispose($notifier.new)',
      );
    });
  }

  static String? _providerTypeFor(String src) =>
      _providerTypes.cast<String?>().firstWhere(
        (t) => src.startsWith(t!),
        orElse: () => null,
      );

  static final _typeArgRe = RegExp(r'<(\w+),\s*\w+>');
  static final _closureRe = RegExp(r'\(\)\s*(?:=>|{\s*return)\s*(\w+)\(\)');
  static final _simpleCtorRe = RegExp(r'(\w+)\(\)(?:\s*;|\s*\})');

  static String? _extractNotifierClassName(String source) {
    return _typeArgRe.firstMatch(source)?.group(1) ??
        _closureRe.firstMatch(source)?.group(1) ??
        _simpleCtorRe.firstMatch(source)?.group(1);
  }
}
