import '../arsync_lint_rule.dart';

/// Rule E2: `Scaffold` is banned inside `lib/widgets/` — pages belong in
/// `lib/screens/`.
class ScaffoldLocation extends AnalysisRule {
  ScaffoldLocation() : super(name: code.lowerCaseName, description: code.problemMessage);

  static const LintCode code = LintCode(
    'scaffold_location',
    'Scaffold is not allowed in widgets folder. Widgets should be fragments, not pages.',
    correctionMessage:
        'Use Container, Column, or a custom card widget instead of Scaffold.',
  );

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    if (!PathUtils.isInWidgets(context.definingUnit.file.path)) return;
    final visitor = _Visitor(this);
    registry
      ..addInstanceCreationExpression(this, visitor)
      ..addMethodInvocation(this, visitor);
  }
}

class _Visitor extends ArsyncRuleVisitor<AnalysisRule> {
  _Visitor(super.rule);

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    if (node.constructorName.type.name.lexeme == 'Scaffold') {
      rule.reportAtNode(node);
    }
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (node.methodName.name == 'Scaffold') rule.reportAtNode(node);
  }
}
