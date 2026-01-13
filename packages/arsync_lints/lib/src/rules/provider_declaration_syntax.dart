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

    // NOTE: We pass context.allUnits to the visitor because definingUnit.content
    // only returns the LIBRARY file content, not part file (.g.dart) content.
    // The visitor must use allUnits to get the correct file's content.

    final visitor = _Visitor(this, context.allUnits);
    registry.addTopLevelVariableDeclaration(this, visitor);
    registry.addFieldDeclaration(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AnalysisRule rule;
  final List<dynamic> allUnits;

  _Visitor(this.rule, this.allUnits);

  @override
  void visitTopLevelVariableDeclaration(TopLevelVariableDeclaration node) {
    // Skip generated files and nodes with ignore comments
    if (NodeContentHelper.shouldSkipNode(node, allUnits, rule.name)) return;

    for (final variable in node.variables.variables) {
      final initializer = variable.initializer;
      if (initializer == null) continue;
      _checkProviderSyntax(initializer);
    }
  }

  @override
  void visitFieldDeclaration(FieldDeclaration node) {
    // Skip generated files and nodes with ignore comments
    if (NodeContentHelper.shouldSkipNode(node, allUnits, rule.name)) return;

    for (final variable in node.fields.variables) {
      final initializer = variable.initializer;
      if (initializer == null) continue;
      _checkProviderSyntax(initializer);
    }
  }

  void _checkProviderSyntax(Expression initializer) {
    final source = initializer.toSource();
    final isTargetedProvider = ProviderDeclarationSyntax._notifierProviderTypes
        .any((type) => source.startsWith(type));

    if (!isTargetedProvider) return;

    final hasTypeArgs = source.contains('<') && source.contains('>');
    final usesClosureInsteadOfNew =
        !source.contains('.new') &&
        (source.contains('() {') || source.contains('() =>'));

    if (hasTypeArgs || usesClosureInsteadOfNew) {
      rule.reportAtNode(initializer);
    }
  }
}
