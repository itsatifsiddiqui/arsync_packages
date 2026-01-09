import 'package:analyzer/source/line_info.dart';

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
    if (!PathUtils.isInWidgets(path)) {
      return;
    }

    final content = context.definingUnit.content;
    final lineInfo = LineInfo.fromContent(content);

    final visitor = _Visitor(this, content, lineInfo);
    registry.addInstanceCreationExpression(this, visitor);
    registry.addMethodInvocation(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AnalysisRule rule;
  final String content;
  final LineInfo lineInfo;

  _Visitor(this.rule, this.content, this.lineInfo);

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    final typeName = node.constructorName.type.name.lexeme;

    if (typeName == 'Scaffold') {
      if (IgnoreUtils.shouldIgnoreAtOffset(
        offset: node.offset,
        lintName: 'scaffold_location',
        content: content,
        lineInfo: lineInfo,
      )) {
        return;
      }
      rule.reportAtNode(node);
    }
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (node.methodName.name == 'Scaffold') {
      if (IgnoreUtils.shouldIgnoreAtOffset(
        offset: node.offset,
        lintName: 'scaffold_location',
        content: content,
        lineInfo: lineInfo,
      )) {
        return;
      }
      rule.reportAtNode(node);
    }
  }
}
