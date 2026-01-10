import '../arsync_lint_rule.dart';

/// Rule E2: scaffold_location
///
/// Pages live in screens; Fragments live in widgets.
/// Ban: Scaffold inside lib/widgets/
class ScaffoldLocation extends AnalysisRule {
  ScaffoldLocation()
      : super(
          name: 'scaffold_location',
          description:
              'Scaffold is not allowed in widgets folder. Widgets should be fragments, not pages.',
        );

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
    final path = context.definingUnit.file.path;
    if (!PathUtils.isInWidgets(path)) return;

    final visitor = _Visitor(this);
    registry.addInstanceCreationExpression(this, visitor);
    registry.addMethodInvocation(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AnalysisRule rule;

  _Visitor(this.rule);

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    if (node.constructorName.type.name.lexeme == 'Scaffold') {
      rule.reportAtNode(node);
    }
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (node.methodName.name == 'Scaffold') {
      rule.reportAtNode(node);
    }
  }
}
