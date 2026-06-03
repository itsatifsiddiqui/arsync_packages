import 'package:analyzer/source/line_info.dart';

import '../arsync_lint_rule.dart';

/// Lint rule: require a blank line between fields, constructors, and `build()`
/// inside a class — improves readability.
class PreferSpaceBetweenElements extends AnalysisRule {
  PreferSpaceBetweenElements()
    : super(name: code.lowerCaseName, description: code.problemMessage);

  static const code = LintCode(
    'prefer_space_between_elements',
    'Ensure there is a blank line between constructor and fields, '
        'and between constructor and build method.',
    correctionMessage: 'Add a blank line between these elements.',
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
    final lineInfo = node.thisOrAncestorOfType<CompilationUnit>()?.lineInfo;
    if (lineInfo == null) return;

    final members = node.classMembers;
    for (var i = 0; i < members.length - 1; i++) {
      final a = members[i];
      final b = members[i + 1];
      if (!_pairNeedsBlankLine(a, b)) continue;
      if (_hasBlankLineBetween(a, b, lineInfo)) continue;
      rule.reportAtNode(b);
    }
  }

  static bool _pairNeedsBlankLine(ClassMember a, ClassMember b) {
    bool isBuild(ClassMember m) =>
        m is MethodDeclaration && m.name.lexeme == 'build';
    if (a is ConstructorDeclaration && isBuild(b)) return true;
    if (a is FieldDeclaration && b is ConstructorDeclaration) return true;
    if (a is ConstructorDeclaration && b is FieldDeclaration) return true;
    if (a is FieldDeclaration && isBuild(b)) return true;
    return false;
  }

  static bool _hasBlankLineBetween(AstNode first, AstNode second, LineInfo li) {
    final endLine = li.getLocation(first.endToken.end).lineNumber;
    final startLine = li.getLocation(second.beginToken.offset).lineNumber;
    return startLine - endLine > 1;
  }
}
