import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../utils.dart';

/// Rule D5: ignore_file_ban
///
/// Developers cannot lazily disable rules for an entire file.
/// Search for string: // ignore_for_file:
class IgnoreFileBan extends DartLintRule {
  const IgnoreFileBan() : super(code: _code);

  static const _code = LintCode(
    name: 'ignore_file_ban',
    problemMessage:
        '// ignore_for_file: is banned. Fix the issue or use line-specific ignores.',
    correctionMessage:
        'Remove the ignore_for_file comment and fix the underlying issue.',
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    // Only apply to lib/ files
    if (!PathUtils.isInLib(resolver.path)) {
      return;
    }

    context.registry.addCompilationUnit((node) {
      // Check all comments in the file
      final sourceContent = resolver.source.contents.data;

      // Find all occurrences of // ignore_for_file:
      final pattern = RegExp(r'//\s*ignore_for_file:');
      final matches = pattern.allMatches(sourceContent);

      for (final match in matches) {
        final offset = match.start;
        final length = match.end - match.start;

        reporter.atOffset(
          offset: offset,
          length: length,
          errorCode: _code,
        );
      }
    });
  }
}
