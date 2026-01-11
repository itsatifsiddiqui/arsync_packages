import 'package:analyzer/source/line_info.dart';

import '../arsync_lint_rule.dart';

/// A lint rule that enforces spacing conventions within class definitions
/// by requiring a blank line between the constructor and fields, and between
/// the constructor and the build method.
///
/// Proper spacing enhances code readability and organization.
///
/// ### Example
///
/// #### BAD:
/// ```dart
/// class MyWidget extends StatelessWidget {
///   final String title;
///   MyWidget(this.title);
///   @override
///   Widget build(BuildContext context) {
///     return Text(title);
///   }
/// }
/// ```
///
/// #### GOOD:
/// ```dart
/// class MyWidget extends StatelessWidget {
///   final String title;
///
///   MyWidget(this.title);
///
///   @override
///   Widget build(BuildContext context) {
///     return Text(title);
///   }
/// }
/// ```
class PreferSpaceBetweenElements extends AnalysisRule {
  PreferSpaceBetweenElements()
      : super(name: code.name, description: code.problemMessage);

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
    final content = context.definingUnit.content;
    final ignoreChecker = IgnoreChecker.forRule(content, name);
    if (ignoreChecker.ignoreForFile) return;

    final visitor = _Visitor(this, ignoreChecker);
    registry.addClassDeclaration(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  _Visitor(this.rule, this.ignoreChecker);

  final AnalysisRule rule;
  final IgnoreChecker ignoreChecker;

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    if (ignoreChecker.shouldIgnore(node)) return;

    final lineInfo = node.thisOrAncestorOfType<CompilationUnit>()?.lineInfo;
    if (lineInfo == null) {
      return;
    }

    final members = node.members;
    for (var i = 0; i < members.length - 1; i++) {
      final currentMember = members[i];
      final nextMember = members[i + 1];

      // No blank line between constructor and build method
      if (currentMember is ConstructorDeclaration &&
          nextMember is MethodDeclaration &&
          nextMember.name.lexeme == 'build') {
        if (!_hasBlankLineBetween(currentMember, nextMember, lineInfo)) {
          rule.reportAtNode(nextMember);
        }
      }

      // No blank line between fields and constructor
      if (currentMember is FieldDeclaration &&
          nextMember is ConstructorDeclaration) {
        if (!_hasBlankLineBetween(currentMember, nextMember, lineInfo)) {
          rule.reportAtNode(nextMember);
        }
      }

      // No blank line between constructor and fields
      if (currentMember is ConstructorDeclaration &&
          nextMember is FieldDeclaration) {
        if (!_hasBlankLineBetween(currentMember, nextMember, lineInfo)) {
          rule.reportAtNode(nextMember);
        }
      }

      // No blank line between fields and build method
      if (currentMember is FieldDeclaration &&
          nextMember is MethodDeclaration &&
          nextMember.name.lexeme == 'build') {
        if (!_hasBlankLineBetween(currentMember, nextMember, lineInfo)) {
          rule.reportAtNode(nextMember);
        }
      }
    }
  }

  /// Returns `true` if there is a blank line between [first] and [second].
  bool _hasBlankLineBetween(AstNode first, AstNode second, LineInfo lineInfo) {
    final firstEndLine = lineInfo.getLocation(first.endToken.end).lineNumber;
    final secondStartLine =
        lineInfo.getLocation(second.beginToken.offset).lineNumber;
    return (secondStartLine - firstEndLine) > 1;
  }
}
