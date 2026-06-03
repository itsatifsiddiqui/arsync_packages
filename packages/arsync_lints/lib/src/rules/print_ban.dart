import '../arsync_lint_rule.dart';

/// Rule D3: `print()` and `debugPrint()` are banned — use the `.log()`
/// extension instead.
class PrintBan extends AnalysisRule {
  PrintBan() : super(name: code.lowerCaseName, description: code.problemMessage);

  static const LintCode code = LintCode(
    'print_ban',
    'print() and debugPrint() are banned. Use .log() extension instead.',
    correctionMessage: 'Replace with your custom logging extension (.log()).',
  );

  @override
  DiagnosticCode get diagnosticCode => code;

  static const _bannedFunctions = {'print', 'debugPrint'};

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    if (!context.isInLibDir) return;
    final visitor = _Visitor(this);
    registry
      ..addMethodInvocation(this, visitor)
      ..addFunctionExpressionInvocation(this, visitor);
  }
}

class _Visitor extends ArsyncRuleVisitor<AnalysisRule> {
  _Visitor(super.rule);

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (node.target == null &&
        PrintBan._bannedFunctions.contains(node.methodName.name)) {
      rule.reportAtNode(node);
    }
  }

  @override
  void visitFunctionExpressionInvocation(FunctionExpressionInvocation node) {
    final f = node.function;
    if (f is SimpleIdentifier && PrintBan._bannedFunctions.contains(f.name)) {
      rule.reportAtNode(node);
    }
  }
}
