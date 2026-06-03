import '../arsync_lint_rule.dart';

/// Rule B3: in `lib/providers/`, no function, method, or constructor may
/// accept `BuildContext` — ViewModels must be UI-agnostic.
class NoContextInProviders extends AnalysisRule {
  NoContextInProviders() : super(name: code.lowerCaseName, description: code.problemMessage);

  static const LintCode code = LintCode(
    'no_context_in_providers',
    'BuildContext cannot be used in providers. ViewModels must be UI-agnostic.',
    correctionMessage: 'Remove BuildContext parameter.',
  );

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
      ..addFunctionDeclaration(this, visitor)
      ..addMethodDeclaration(this, visitor)
      ..addConstructorDeclaration(this, visitor);
  }
}

class _Visitor extends ArsyncRuleVisitor<AnalysisRule> {
  _Visitor(super.rule);

  @override
  void visitFunctionDeclaration(FunctionDeclaration node) {
    _check(node, node.functionExpression.parameters);
  }

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    _check(node, node.parameters);
  }

  @override
  void visitConstructorDeclaration(ConstructorDeclaration node) {
    _check(node, node.parameters);
  }

  void _check(AstNode parent, FormalParameterList? params) {
    if (params == null) return;
    for (final p in params.parameters) {
      if (_typeName(p) == 'BuildContext') rule.reportAtNode(p);
    }
  }

  static String? _typeName(FormalParameter p) {
    if (p is! SimpleFormalParameter) return null;
    final t = p.type;
    return t is NamedType ? t.name.lexeme : null;
  }
}
