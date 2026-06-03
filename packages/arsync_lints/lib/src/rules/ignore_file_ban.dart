import '../arsync_lint_rule.dart';

/// Rule D5: `// ignore_for_file:` is banned — use line-specific ignores or
/// fix the underlying issue.
class IgnoreFileBan extends AnalysisRule {
  IgnoreFileBan() : super(name: code.lowerCaseName, description: code.problemMessage);

  static const LintCode code = LintCode(
    'ignore_file_ban',
    '// ignore_for_file: is banned. Fix the issue or use line-specific ignores.',
    correctionMessage:
        'Remove the ignore_for_file comment and fix the underlying issue.',
  );

  @override
  DiagnosticCode get diagnosticCode => code;

  static final _pattern = RegExp(r'//\s*ignore_for_file:');

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    if (!context.isInLibDir) return;
    registry.addCompilationUnit(this, _Visitor(this, context));
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  _Visitor(this.rule, this.context);

  final AnalysisRule rule;
  final RuleContext context;

  @override
  void visitCompilationUnit(CompilationUnit node) {
    final content = context.currentUnit?.content;
    if (content == null) return;
    for (final match in IgnoreFileBan._pattern.allMatches(content)) {
      rule.reportAtOffset(match.start, match.end - match.start);
    }
  }
}
