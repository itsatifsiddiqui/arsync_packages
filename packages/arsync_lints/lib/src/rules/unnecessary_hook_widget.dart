import '../arsync_lint_rule.dart';

final _hookNameRegex = RegExp(r'^_?use[A-Z].*');

/// Lint rule: a class extending `HookWidget` that uses no hooks should be a
/// `StatelessWidget` instead.
class UnnecessaryHookWidget extends AnalysisRule {
  UnnecessaryHookWidget()
    : super(name: code.lowerCaseName, description: code.problemMessage);

  static const code = LintCode(
    'unnecessary_hook_widget',
    'Consider using StatelessWidget instead of HookWidget when no hooks are used.',
    correctionMessage: 'Replace with StatelessWidget.',
  );

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    registry.addClassDeclaration(this, _Visitor(this));
  }
}

class _Visitor extends ArsyncRuleVisitor<AnalysisRule> {
  _Visitor(super.rule);

  @override
  void visitClassDeclaration(ClassDeclaration node) {

    final superclass = node.extendsClause?.superclass;
    if (superclass == null || superclass.name.lexeme != 'HookWidget') return;

    final detector = _HookDetectorVisitor();
    node.visitChildren(detector);
    if (!detector.found) rule.reportAtNode(superclass);
  }
}

class _HookDetectorVisitor extends RecursiveAstVisitor<void> {
  bool found = false;

  bool _isHookName(String name) => _hookNameRegex.hasMatch(name);

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (_isHookName(node.methodName.name)) {
      found = true;
    } else {
      final target = node.realTarget;
      if (target is SimpleIdentifier && _isHookName(target.name)) {
        found = true;
      }
    }
    super.visitMethodInvocation(node);
  }

  @override
  void visitFunctionExpressionInvocation(FunctionExpressionInvocation node) {
    final f = node.function;
    if (f is SimpleIdentifier && _isHookName(f.name)) found = true;
    super.visitFunctionExpressionInvocation(node);
  }
}
