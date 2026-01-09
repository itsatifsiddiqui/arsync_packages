import 'package:analyzer/source/line_info.dart';

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

    final content = context.definingUnit.content;
    final lineInfo = LineInfo.fromContent(content);

    final visitor = _Visitor(this, content, lineInfo);
    registry.addCompilationUnit(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AnalysisRule rule;
  final String content;
  final LineInfo lineInfo;

  _Visitor(this.rule, this.content, this.lineInfo);

  @override
  void visitCompilationUnit(CompilationUnit node) {
    // Find all occurrences of // ignore_for_file:
    final pattern = RegExp(r'//\s*ignore_for_file:');
    final matches = pattern.allMatches(content);

    for (final match in matches) {
      final offset = match.start;
      final length = match.end - match.start;

      if (IgnoreUtils.shouldIgnoreAtOffset(
        offset: offset,
        lintName: 'ignore_file_ban',
        content: content,
        lineInfo: lineInfo,
      )) {
        continue;
      }

      rule.reportAtOffset(offset, length);
    }
  }
}
