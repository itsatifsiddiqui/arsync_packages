import '../arsync_lint_rule.dart';

/// Rule D3: print_ban
///
/// Production apps should not spam the console.
/// Banned: print(), debugPrint()
class PrintBan extends AnalysisRule {
  PrintBan()
      : super(
          name: 'print_ban',
          description:
              'print() and debugPrint() are banned. Use .log() extension instead.',
        );

  static const LintCode code = LintCode(
    'print_ban',
    'print() and debugPrint() are banned. Use .log() extension instead.',
    correctionMessage: 'Replace with your custom logging extension (.log()).',
  );

  @override
  DiagnosticCode get diagnosticCode => code;

  static const _bannedFunctions = ['print', 'debugPrint'];

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    // Only apply to lib/ files
    if (!context.isInLibDir) {
      return;
    }

    var visitor = _Visitor(this);
    registry.addMethodInvocation(this, visitor);
    registry.addFunctionExpressionInvocation(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AnalysisRule rule;

  _Visitor(this.rule);

  @override
  void visitMethodInvocation(MethodInvocation node) {
    final methodName = node.methodName.name;

    if (PrintBan._bannedFunctions.contains(methodName)) {
      // Make sure it's a top-level function call, not a method on an object
      if (node.target == null) {
        rule.reportAtNode(node);
      }
    }
  }

  @override
  void visitFunctionExpressionInvocation(FunctionExpressionInvocation node) {
    final function = node.function;
    if (function is SimpleIdentifier) {
      if (PrintBan._bannedFunctions.contains(function.name)) {
        rule.reportAtNode(node);
      }
    }
  }
}
