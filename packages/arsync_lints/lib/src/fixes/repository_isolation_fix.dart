import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';

/// Quick fix for `repository_isolation` rule - remove banned import.
///
/// Removes the UI/ViewModel import that violates repository isolation.
class RepositoryIsolationFix extends ResolvedCorrectionProducer {
  RepositoryIsolationFix({required super.context});

  static const _fixKind = FixKind(
    'arsync.fix.repositoryIsolation',
    100,
    'Remove banned import',
  );

  @override
  FixKind? get fixKind => _fixKind;

  @override
  CorrectionApplicability get applicability =>
      CorrectionApplicability.singleLocation;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final importDirective = _findImportDirective(node);
    if (importDirective == null) return;

    final lineInfo = unitResult.lineInfo;
    final startLine = lineInfo.getLocation(importDirective.offset).lineNumber - 1;
    final lineStart = lineInfo.getOffsetOfLine(startLine);

    var lineEnd = importDirective.end;
    final content = unitResult.content;
    while (lineEnd < content.length && content[lineEnd] != '\n') {
      lineEnd++;
    }
    if (lineEnd < content.length && content[lineEnd] == '\n') {
      lineEnd++;
    }

    await builder.addDartFileEdit(file, (builder) {
      builder.addDeletion(SourceRange(lineStart, lineEnd - lineStart));
    });
  }

  ImportDirective? _findImportDirective(AstNode? node) {
    if (node == null) return null;
    if (node is ImportDirective) return node;

    AstNode? current = node;
    while (current != null) {
      if (current is ImportDirective) return current;
      current = current.parent;
    }
    return null;
  }
}
