import '../arsync_lint_rule.dart';

/// Rule B3: no_context_in_providers
///
/// ViewModels must be UI-agnostic. BuildContext cannot be used as a parameter.
class NoContextInProviders extends AnalysisRule {
  NoContextInProviders()
    : super(
        name: 'no_context_in_providers',
        description:
            'BuildContext cannot be used in providers. ViewModels must be UI-agnostic.',
      );

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
    final path = context.definingUnit.file.path;
    if (!PathUtils.isInProviders(path)) return;

    final content = context.definingUnit.content;
    final ignoreChecker = IgnoreChecker.forRule(content, name);
    if (ignoreChecker.ignoreForFile) return;

    var visitor = _Visitor(this, ignoreChecker);
    registry.addFunctionDeclaration(this, visitor);
    registry.addMethodDeclaration(this, visitor);
    registry.addConstructorDeclaration(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AnalysisRule rule;
  final IgnoreChecker ignoreChecker;

  _Visitor(this.rule, this.ignoreChecker);

  @override
  void visitFunctionDeclaration(FunctionDeclaration node) {
    _checkParameters(node.functionExpression.parameters);
  }

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    _checkParameters(node.parameters);
  }

  @override
  void visitConstructorDeclaration(ConstructorDeclaration node) {
    _checkParameters(node.parameters);
  }

  void _checkParameters(FormalParameterList? parameters) {
    if (parameters == null) return;

    for (final param in parameters.parameters) {
      if (ignoreChecker.shouldIgnore(param)) continue;
      final typeName = _getParameterTypeName(param);
      if (typeName == 'BuildContext') {
        rule.reportAtNode(param);
      }
    }
  }

  String? _getParameterTypeName(FormalParameter param) {
    if (param is SimpleFormalParameter) {
      final type = param.type;
      if (type is NamedType) {
        return type.name.lexeme;
      }
    } else if (param is DefaultFormalParameter) {
      return _getParameterTypeName(param.parameter);
    }
    return null;
  }
}
