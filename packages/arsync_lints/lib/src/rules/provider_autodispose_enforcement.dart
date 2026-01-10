import '../arsync_lint_rule.dart';

/// Rule B1: provider_autodispose_enforcement
///
/// To prevent memory leaks, all providers must use .autoDispose by default.
/// Exception: providers/core/ contains infrastructure providers (Dio, etc.)
/// that should persist throughout the app lifecycle.
class ProviderAutodisposeEnforcement extends AnalysisRule {
  ProviderAutodisposeEnforcement()
      : super(
          name: 'provider_autodispose_enforcement',
          description: 'Providers must use .autoDispose to prevent memory leaks.',
        );

  static const LintCode code = LintCode(
    'provider_autodispose_enforcement',
    'Providers must use .autoDispose to prevent memory leaks.',
    correctionMessage:
        'Add .autoDispose to the provider or call ref.keepAlive() inside it.',
  );

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    final path = context.definingUnit.file.path;
    if (!PathUtils.isInProviders(path)) return;
    if (path.contains('providers/core/')) return;

    var visitor = _Visitor(this);
    registry.addTopLevelVariableDeclaration(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AnalysisRule rule;

  _Visitor(this.rule);

  @override
  void visitTopLevelVariableDeclaration(TopLevelVariableDeclaration node) {
    for (final variable in node.variables.variables) {
      final name = variable.name.lexeme;
      if (!name.endsWith('Provider')) continue;

      final initializer = variable.initializer;
      if (initializer == null) continue;

      final initializerSource = initializer.toSource();
      final hasAutoDispose = initializerSource.contains('autoDispose') ||
          initializerSource.contains('.autoDispose');
      final hasKeepAlive = initializerSource.contains('ref.keepAlive()') ||
          initializerSource.contains('ref.keepAlive(');

      if (!hasAutoDispose && !hasKeepAlive) {
        rule.reportAtOffset(variable.name.offset, variable.name.length);
      }
    }
  }
}
