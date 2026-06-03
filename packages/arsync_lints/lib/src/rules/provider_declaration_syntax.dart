import '../arsync_lint_rule.dart';

/// Rule: `NotifierProvider` (and async/stream variants) must use the
/// `.new` constructor form without explicit type arguments — i.e.
/// `NotifierProvider.autoDispose(MyNotifier.new)` rather than
/// `NotifierProvider.autoDispose<MyNotifier, State>(() => MyNotifier())`.
class ProviderDeclarationSyntax extends AnalysisRule {
  ProviderDeclarationSyntax()
    : super(name: code.lowerCaseName, description: code.problemMessage);

  static const LintCode code = LintCode(
    'provider_declaration_syntax',
    'NotifierProvider should use .new constructor syntax without explicit generic parameters.',
    correctionMessage:
        'Use NotifierProvider.autoDispose(MyNotifier.new) instead of '
        'NotifierProvider.autoDispose<MyNotifier, State>(() => MyNotifier()).',
  );

  static const _notifierProviderTypes = {
    'NotifierProvider',
    'AsyncNotifierProvider',
    'StreamNotifierProvider',
  };

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    if (!PathUtils.isInProviders(context.definingUnit.file.path)) return;
    final visitor = _Visitor(this);
    registry
      ..addTopLevelVariableDeclaration(this, visitor)
      ..addFieldDeclaration(this, visitor);
  }
}

class _Visitor extends ArsyncRuleVisitor<AnalysisRule> {
  _Visitor(super.rule);

  @override
  void visitTopLevelVariableDeclaration(TopLevelVariableDeclaration node) =>
      _check(node.variables.variables);

  @override
  void visitFieldDeclaration(FieldDeclaration node) =>
      _check(node.fields.variables);

  void _check(List<VariableDeclaration> variables) {
    for (final v in variables) {
      final init = v.initializer;
      if (init is! InstanceCreationExpression) continue;
      if (!ProviderDeclarationSyntax._notifierProviderTypes.contains(
        init.typeName,
      )) {
        continue;
      }

      final hasTypeArgs =
          init.constructorName.type.typeArguments?.arguments.isNotEmpty ?? false;
      final usesEmptyParenClosure = init.argumentList.arguments.any(
        (a) =>
            a is FunctionExpression &&
            (a.parameters?.parameters.isEmpty ?? true),
      );

      if (hasTypeArgs || usesEmptyParenClosure) rule.reportAtNode(init);
    }
  }
}
