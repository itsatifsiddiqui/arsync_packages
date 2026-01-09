import 'package:analyzer/source/line_info.dart';

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

    final content = context.definingUnit.content;
    final lineInfo = LineInfo.fromContent(content);

    var visitor = _Visitor(this, content, lineInfo);
    registry.addMethodInvocation(this, visitor);
    registry.addFunctionExpressionInvocation(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AnalysisRule rule;
  final String content;
  final LineInfo lineInfo;

  _Visitor(this.rule, this.content, this.lineInfo);

  @override
  void visitMethodInvocation(MethodInvocation node) {
    final methodName = node.methodName.name;

    if (PrintBan._bannedFunctions.contains(methodName)) {
      // Make sure it's a top-level function call, not a method on an object
      if (node.target == null) {
        if (IgnoreUtils.shouldIgnoreAtOffset(
          offset: node.offset,
          lintName: 'print_ban',
          content: content,
          lineInfo: lineInfo,
        )) return;
        rule.reportAtNode(node);
      }
    }
  }

  @override
  void visitFunctionExpressionInvocation(FunctionExpressionInvocation node) {
    final function = node.function;
    if (function is SimpleIdentifier) {
      if (PrintBan._bannedFunctions.contains(function.name)) {
        if (IgnoreUtils.shouldIgnoreAtOffset(
          offset: node.offset,
          lintName: 'print_ban',
          content: content,
          lineInfo: lineInfo,
        )) return;
        rule.reportAtNode(node);
      }
    }
  }
}
