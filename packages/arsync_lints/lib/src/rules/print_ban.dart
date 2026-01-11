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

    final content = context.definingUnit.content;
    final ignoreChecker = IgnoreChecker.forRule(content, name);
    if (ignoreChecker.ignoreForFile) return;

    var visitor = _Visitor(this, ignoreChecker);
    registry.addMethodInvocation(this, visitor);
    registry.addFunctionExpressionInvocation(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AnalysisRule rule;
  final IgnoreChecker ignoreChecker;

  _Visitor(this.rule, this.ignoreChecker);

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (ignoreChecker.shouldIgnore(node)) return;
    final methodName = node.methodName.name;
    if (PrintBan._bannedFunctions.contains(methodName) && node.target == null) {
      rule.reportAtNode(node);
    }
  }

  @override
  void visitFunctionExpressionInvocation(FunctionExpressionInvocation node) {
    if (ignoreChecker.shouldIgnore(node)) return;
    final function = node.function;
    if (function is SimpleIdentifier &&
        PrintBan._bannedFunctions.contains(function.name)) {
      rule.reportAtNode(node);
    }
  }
}
