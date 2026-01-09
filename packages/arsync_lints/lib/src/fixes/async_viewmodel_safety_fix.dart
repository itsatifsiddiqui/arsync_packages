import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';

/// Quick fix for `async_viewmodel_safety` rule.
///
/// Wraps await expression in try-catch:
/// - Before: `await repository.fetch();`
/// - After:
///   ```
///   try {
///     await repository.fetch();
///   } catch (e) {
///     ref.showExceptionSheet(e);
///   }
///   ```
class AsyncViewModelSafetyFix extends ResolvedCorrectionProducer {
  AsyncViewModelSafetyFix({required super.context});

  static const _fixKind = FixKind(
    'arsync.fix.asyncViewModelSafety',
    100,
    'Wrap in try-catch block',
  );

  @override
  FixKind? get fixKind => _fixKind;

  @override
  CorrectionApplicability get applicability =>
      CorrectionApplicability.singleLocation;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    // Find the statement containing the await expression
    final statement = _findStatement(node);
    if (statement == null) return;

    // Get the indentation of the current statement
    final lineInfo = unitResult.lineInfo;
    final statementLine = lineInfo.getLocation(statement.offset).lineNumber - 1;
    final lineStart = lineInfo.getOffsetOfLine(statementLine);
    final content = unitResult.content;

    // Calculate indentation
    var indent = '';
    for (var i = lineStart; i < statement.offset; i++) {
      final char = content[i];
      if (char == ' ' || char == '\t') {
        indent += char;
      } else {
        break;
      }
    }

    final statementSource = statement.toSource();

    // Build the try-catch block
    final tryCatch =
        '''try {
$indent  $statementSource
$indent} catch (e) {
$indent  ref.showExceptionSheet(e);
$indent}''';

    await builder.addDartFileEdit(file, (builder) {
      builder.addSimpleReplacement(
        SourceRange(statement.offset, statement.length),
        tryCatch,
      );
    });
  }

  Statement? _findStatement(AstNode? node) {
    if (node == null) return null;

    AstNode? current = node;
    while (current != null) {
      if (current is Statement && current is! Block) {
        return current;
      }
      current = current.parent;
    }
    return null;
  }
}
