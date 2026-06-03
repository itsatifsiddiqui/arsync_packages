import '../arsync_lint_rule.dart';

/// Rule B1: provider_autodispose_enforcement
///
/// To prevent memory leaks, all providers must use .autoDispose by default.
/// Exception: providers/core/ contains infrastructure providers (Dio, etc.)
/// that should persist throughout the app lifecycle.
class ProviderAutodisposeEnforcement extends AnalysisRule {
  ProviderAutodisposeEnforcement()
    : super(name: code.lowerCaseName, description: code.problemMessage);

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
    registry.addTopLevelVariableDeclaration(this, _Visitor(this));
  }
}

class _Visitor extends ArsyncRuleVisitor<AnalysisRule> {
  _Visitor(super.rule);

  @override
  void visitTopLevelVariableDeclaration(TopLevelVariableDeclaration node) {
    for (final variable in node.variables.variables) {
      if (!variable.name.lexeme.endsWith('Provider')) continue;
      final initializer = variable.initializer;
      if (initializer == null) continue;

      final scanner = _AutoDisposeScanner();
      initializer.accept(scanner);
      if (scanner.hasAutoDispose || scanner.hasKeepAlive) continue;

      rule.reportAtOffset(variable.name.offset, variable.name.length);
    }
  }
}

/// Walks the initializer AST looking for either `.autoDispose` (anywhere) or
/// `ref.keepAlive(...)` (anywhere — including inside the provider's closure).
class _AutoDisposeScanner extends RecursiveAstVisitor<void> {
  bool hasAutoDispose = false;
  bool hasKeepAlive = false;

  @override
  void visitMethodInvocation(MethodInvocation node) {
    final name = node.methodName.name;
    if (name == 'autoDispose') {
      hasAutoDispose = true;
    } else if (name == 'keepAlive') {
      final target = node.target;
      if (target is SimpleIdentifier && target.name == 'ref') {
        hasKeepAlive = true;
      }
    }
    super.visitMethodInvocation(node);
  }

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    // `XxxProvider.autoDispose(...)` — autoDispose appears as the named
    // constructor name in the AST.
    if (node.constructorName.name?.name == 'autoDispose') {
      hasAutoDispose = true;
    }
    super.visitInstanceCreationExpression(node);
  }

  @override
  void visitFunctionExpressionInvocation(FunctionExpressionInvocation node) {
    // Riverpod 3.x: `NotifierProvider.autoDispose(X.new)` is parsed as a
    // FunctionExpressionInvocation whose `function` is a PropertyAccess or
    // PrefixedIdentifier ending in `autoDispose`.
    final function = node.function;
    if (function is PropertyAccess &&
        function.propertyName.name == 'autoDispose') {
      hasAutoDispose = true;
    } else if (function is PrefixedIdentifier &&
        function.identifier.name == 'autoDispose') {
      hasAutoDispose = true;
    }
    super.visitFunctionExpressionInvocation(node);
  }

  @override
  void visitPropertyAccess(PropertyAccess node) {
    // Catches chains like `FutureProvider.autoDispose.family<X,Y>(...)`.
    if (node.propertyName.name == 'autoDispose') {
      hasAutoDispose = true;
    }
    super.visitPropertyAccess(node);
  }

  @override
  void visitPrefixedIdentifier(PrefixedIdentifier node) {
    // Catches `XxxProvider.autoDispose` used as a value (e.g., tear-offs).
    if (node.identifier.name == 'autoDispose') {
      hasAutoDispose = true;
    }
    super.visitPrefixedIdentifier(node);
  }
}
