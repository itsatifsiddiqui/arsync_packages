import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';

/// Quick fix for `repository_no_try_catch` rule.
///
/// Removes the try-catch block and keeps only the try body.
class RepositoryNoTryCatchFix extends ResolvedCorrectionProducer {
  RepositoryNoTryCatchFix({required super.context});

  static const _fixKind = FixKind(
    'arsync.fix.repositoryNoTryCatch',
    100,
    'Remove try-catch block (keep try body)',
  );

  @override
  FixKind? get fixKind => _fixKind;

  @override
  CorrectionApplicability get applicability =>
      CorrectionApplicability.singleLocation;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final tryStatement = _findTryStatement(node);
    if (tryStatement == null) return;

    // Extract the body of the try block
    final tryBody = tryStatement.body;

    // Get the statements inside the try body
    final statements = tryBody.statements;
    if (statements.isEmpty) return;

    // Get indentation of the try statement
    final lineInfo = unitResult.lineInfo;
    final tryLine = lineInfo.getLocation(tryStatement.offset).lineNumber - 1;
    final lineStart = lineInfo.getOffsetOfLine(tryLine);
    final content = unitResult.content;

    var indent = '';
    for (var i = lineStart; i < tryStatement.offset; i++) {
      final char = content[i];
      if (char == ' ' || char == '\t') {
        indent += char;
      } else {
        break;
      }
    }

    // Build the replacement - just the statements from try body
    final bodySource = statements
        .map((s) => '$indent${s.toSource()}')
        .join('\n');

    await builder.addDartFileEdit(file, (builder) {
      builder.addSimpleReplacement(
        SourceRange(tryStatement.offset, tryStatement.length),
        bodySource,
      );
    });
  }

  TryStatement? _findTryStatement(AstNode? node) {
    if (node == null) return null;
    if (node is TryStatement) return node;

    AstNode? current = node;
    while (current != null) {
      if (current is TryStatement) return current;
      current = current.parent;
    }
    return null;
  }
}
