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
    if (!context.isInLibDir) return;

    // NOTE: We pass context.allUnits to the visitor because definingUnit.content
    // only returns the LIBRARY file content, not part file (.g.dart) content.
    final visitor = _Visitor(this, context.allUnits);
    registry.addMethodInvocation(this, visitor);
    registry.addFunctionExpressionInvocation(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AnalysisRule rule;
  final List<dynamic> allUnits;

  _Visitor(this.rule, this.allUnits);

  @override
  void visitMethodInvocation(MethodInvocation node) {
    // Skip generated files and nodes with ignore comments
    if (NodeContentHelper.shouldSkipNode(node, allUnits, rule.name)) return;

    final methodName = node.methodName.name;
    if (PrintBan._bannedFunctions.contains(methodName) && node.target == null) {
      rule.reportAtNode(node);
    }
  }

  @override
  void visitFunctionExpressionInvocation(FunctionExpressionInvocation node) {
    // Skip generated files and nodes with ignore comments
    if (NodeContentHelper.shouldSkipNode(node, allUnits, rule.name)) return;

    final function = node.function;
    if (function is SimpleIdentifier &&
        PrintBan._bannedFunctions.contains(function.name)) {
      rule.reportAtNode(node);
    }
  }
}
