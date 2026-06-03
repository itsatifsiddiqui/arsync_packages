import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';

/// Shared helpers for quick-fix implementations.
class FixHelpers {
  /// Deletes the entire source line(s) containing [node], including the
  /// trailing newline. Used by import-removal and similar fixes.
  static Future<void> deleteLine(
    ChangeBuilder builder,
    ResolvedUnitResult unitResult,
    String file,
    AstNode node,
  ) async {
    final lineInfo = unitResult.lineInfo;
    final startLine = lineInfo.getLocation(node.offset).lineNumber - 1;
    final lineStart = lineInfo.getOffsetOfLine(startLine);

    final content = unitResult.content;
    var lineEnd = node.end;
    while (lineEnd < content.length && content[lineEnd] != '\n') {
      lineEnd++;
    }
    if (lineEnd < content.length && content[lineEnd] == '\n') {
      lineEnd++;
    }

    await builder.addDartFileEdit(file, (b) {
      b.addDeletion(SourceRange(lineStart, lineEnd - lineStart));
    });
  }

  /// Returns the leading whitespace of the source line that contains [offset].
  static String indentOf(ResolvedUnitResult unitResult, int offset) {
    final lineInfo = unitResult.lineInfo;
    final line = lineInfo.getLocation(offset).lineNumber - 1;
    final lineStart = lineInfo.getOffsetOfLine(line);
    final content = unitResult.content;
    var i = lineStart;
    final buf = StringBuffer();
    while (i < content.length && (content[i] == ' ' || content[i] == '\t')) {
      buf.write(content[i]);
      i++;
    }
    return buf.toString();
  }
}
