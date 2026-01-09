import 'package:analyzer/source/line_info.dart';

import '../arsync_lint_rule.dart';

/// Rule D4: barrel_file_restriction
///
/// Explicit imports are preferred to maintain layer visibility.
/// Banned in: lib/screens/, lib/features/, lib/providers/
/// Allowed in: lib/utils/, lib/widgets/, lib/models/
class BarrelFileRestriction extends AnalysisRule {
  BarrelFileRestriction()
      : super(
          name: 'barrel_file_restriction',
          description:
              'Barrel files (index.dart or export-only files) are not allowed in screens, features, or providers folders.',
        );

  static const LintCode code = LintCode(
    'barrel_file_restriction',
    'Barrel files (index.dart or export-only files) are not allowed in screens, features, or providers folders.',
    correctionMessage: 'Use explicit imports instead of barrel files.',
  );

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    final filePath = context.definingUnit.file.path;
    final fileName = PathUtils.getFileNameWithExtension(filePath);

    // Check if file is in banned locations
    final isInBannedLocation = PathUtils.isInScreens(filePath) ||
        PathUtils.isInFeatures(filePath) ||
        PathUtils.isInProviders(filePath);

    if (!isInBannedLocation) return;

    final content = context.definingUnit.content;
    final lineInfo = LineInfo.fromContent(content);

    final visitor = _Visitor(this, fileName, content, lineInfo);
    registry.addCompilationUnit(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AnalysisRule rule;
  final String fileName;
  final String content;
  final LineInfo lineInfo;

  _Visitor(this.rule, this.fileName, this.content, this.lineInfo);

  @override
  void visitCompilationUnit(CompilationUnit node) {
    // Check if file is named index.dart
    if (fileName == 'index.dart') {
      if (IgnoreUtils.shouldIgnoreAtOffset(
        offset: node.offset,
        lintName: 'barrel_file_restriction',
        content: content,
        lineInfo: lineInfo,
      )) {
        return;
      }
      rule.reportAtNode(node);
      return;
    }

    // Check if file only contains export statements
    final directives = node.directives;
    final declarations = node.declarations;

    // If file has no declarations and only has export directives
    if (declarations.isEmpty) {
      final hasOnlyExports = directives.every((directive) =>
          directive is ExportDirective || directive is LibraryDirective);

      final hasExports =
          directives.any((directive) => directive is ExportDirective);

      if (hasOnlyExports && hasExports) {
        if (IgnoreUtils.shouldIgnoreAtOffset(
          offset: node.offset,
          lintName: 'barrel_file_restriction',
          content: content,
          lineInfo: lineInfo,
        )) {
          return;
        }
        rule.reportAtNode(node);
      }
    }
  }
}
