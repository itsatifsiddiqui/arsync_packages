import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';

/// Quick fix for `ignore_file_ban` rule.
///
/// Removes the ignore_for_file comment:
/// - Before: `// ignore_for_file: some_lint`
/// - After: (line removed)
class IgnoreFileBanFix extends ResolvedCorrectionProducer {
  IgnoreFileBanFix({required super.context});

  static const _fixKind = FixKind(
    'arsync.fix.ignoreFileBan',
    100,
    'Remove ignore_for_file comment',
  );

  @override
  FixKind? get fixKind => _fixKind;

  @override
  CorrectionApplicability get applicability =>
      CorrectionApplicability.singleLocation;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    // The diagnostic is reported at the start of "// ignore_for_file:"
    // We need to find and remove the entire line

    final content = unitResult.content;
    final diagnosticMessage = diagnostic?.problemMessage;
    if (diagnosticMessage == null) return;
    final diagnosticOffset = diagnosticMessage.offset;

    // Find the start of the line
    var lineStart = diagnosticOffset;
    while (lineStart > 0 && content[lineStart - 1] != '\n') {
      lineStart--;
    }

    // Find the end of the line (including newline if present)
    var lineEnd = diagnosticOffset;
    while (lineEnd < content.length && content[lineEnd] != '\n') {
      lineEnd++;
    }
    if (lineEnd < content.length && content[lineEnd] == '\n') {
      lineEnd++; // Include the newline
    }

    await builder.addDartFileEdit(file, (builder) {
      builder.addDeletion(SourceRange(lineStart, lineEnd - lineStart));
    });
  }
}
