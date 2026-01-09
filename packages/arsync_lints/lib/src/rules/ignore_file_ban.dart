import '../arsync_lint_rule.dart';

/// Rule D5: ignore_file_ban
///
/// Developers cannot lazily disable rules for an entire file.
/// Search for string: // ignore_for_file:
class IgnoreFileBan extends AnalysisRule {
  IgnoreFileBan()
      : super(
          name: 'ignore_file_ban',
          description:
              '// ignore_for_file: is banned. Fix the issue or use line-specific ignores.',
        );

  static const LintCode code = LintCode(
    'ignore_file_ban',
    '// ignore_for_file: is banned. Fix the issue or use line-specific ignores.',
    correctionMessage:
        'Remove the ignore_for_file comment and fix the underlying issue.',
  );

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    if (!context.isInLibDir) {
      return;
    }

    final visitor = _Visitor(this, context);
    registry.addCompilationUnit(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AnalysisRule rule;
  final RuleContext context;

  _Visitor(this.rule, this.context);

  @override
  void visitCompilationUnit(CompilationUnit node) {
    // Check all comments in the file
    final sourceContent = context.definingUnit.content;

    // Find all occurrences of // ignore_for_file:
    final pattern = RegExp(r'//\s*ignore_for_file:');
    final matches = pattern.allMatches(sourceContent);

    for (final match in matches) {
      final offset = match.start;
      final length = match.end - match.start;

      rule.reportAtOffset(offset, length);
    }
  }
}
