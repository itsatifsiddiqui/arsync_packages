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

  static final _pattern = RegExp(r'//\s*ignore_for_file:');

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    if (!context.isInLibDir) return;

    // NOTE: We pass context.allUnits to the visitor because definingUnit.content
    // only returns the LIBRARY file content, not part file (.g.dart) content.
    // The visitor must use allUnits to get the correct file's content.

    final visitor = _Visitor(this, context.allUnits);
    registry.addCompilationUnit(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AnalysisRule rule;
  final List<dynamic> allUnits;

  _Visitor(this.rule, this.allUnits);

  @override
  void visitCompilationUnit(CompilationUnit node) {
    // Skip generated files
    final content = NodeContentHelper.getContentForNode(node, allUnits);
    if (content == null) return;
    if (PathUtils.isGeneratedFile(content)) return;

    final ignoreChecker = IgnoreChecker.forRule(content, rule.name);
    if (ignoreChecker.ignoreForFile) return;

    final matches = IgnoreFileBan._pattern.allMatches(content);

    for (final match in matches) {
      final offset = match.start;
      if (ignoreChecker.shouldIgnoreOffset(offset)) continue;
      final length = match.end - match.start;
      rule.reportAtOffset(offset, length);
    }
  }
}
