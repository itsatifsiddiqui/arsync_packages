import '../arsync_lint_rule.dart';

/// Rule: provider_declaration_syntax
///
/// Enforce clean provider declaration syntax:
/// 1. NotifierProvider must use .new constructor syntax (e.g., AuthNotifier.new)
/// 2. NotifierProvider must not have explicit generic type parameters
///
/// Good: `final authProvider = NotifierProvider.autoDispose(AuthNotifier.new);`
/// Bad:  `final authProvider = NotifierProvider.autoDispose<AuthNotifier, AuthState>(() => AuthNotifier());`
class ProviderDeclarationSyntax extends AnalysisRule {
  ProviderDeclarationSyntax()
      : super(
          name: 'provider_declaration_syntax',
          description:
              'NotifierProvider should use .new constructor syntax without explicit generic parameters.',
        );

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
    final path = context.definingUnit.file.path;
    if (!PathUtils.isInProviders(path)) return;

    final visitor = _Visitor(this);
    registry.addTopLevelVariableDeclaration(this, visitor);
    registry.addFieldDeclaration(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AnalysisRule rule;

  _Visitor(this.rule);

  @override
  void visitTopLevelVariableDeclaration(TopLevelVariableDeclaration node) {
    for (final variable in node.variables.variables) {
      final initializer = variable.initializer;
      if (initializer == null) continue;
      _checkProviderSyntax(initializer);
    }
  }

  @override
  void visitFieldDeclaration(FieldDeclaration node) {
    for (final variable in node.fields.variables) {
      final initializer = variable.initializer;
      if (initializer == null) continue;
      _checkProviderSyntax(initializer);
    }
  }

  void _checkProviderSyntax(Expression initializer) {
    final source = initializer.toSource();
    final isTargetedProvider = ProviderDeclarationSyntax._notifierProviderTypes.any(
      (type) => source.startsWith(type),
    );

    if (!isTargetedProvider) return;

    final hasTypeArgs = source.contains('<') && source.contains('>');
    final usesClosureInsteadOfNew = !source.contains('.new') &&
        (source.contains('() {') || source.contains('() =>'));

    if (hasTypeArgs || usesClosureInsteadOfNew) {
      rule.reportAtNode(initializer);
    }
  }
}
