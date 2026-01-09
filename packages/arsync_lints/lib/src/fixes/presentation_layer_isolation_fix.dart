import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';

/// Quick fix for `presentation_layer_isolation` rule - remove banned import.
///
/// Removes the import statement that violates presentation layer isolation.
class PresentationLayerIsolationImportFix extends ResolvedCorrectionProducer {
  PresentationLayerIsolationImportFix({required super.context});

  static const _fixKind = FixKind(
    'arsync.fix.presentationLayerIsolationImport',
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

    // Remove the entire import line including newline
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

/// Quick fix for `presentation_layer_isolation` rule - convert class to record.
///
/// Converts a simple parameter class to a Dart record typedef.
class PresentationLayerUseRecordFix extends ResolvedCorrectionProducer {
  PresentationLayerUseRecordFix({required super.context});

  static const _fixKind = FixKind(
    'arsync.fix.presentationLayerUseRecord',
    100,
    'Convert to record typedef',
  );

  @override
  FixKind? get fixKind => _fixKind;

  @override
  CorrectionApplicability get applicability =>
      CorrectionApplicability.singleLocation;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final classDecl = _findClassDeclaration(node);
    if (classDecl == null) return;

    final className = classDecl.name.lexeme;
    final fields = <String>[];

    // Extract fields from the class
    for (final member in classDecl.members) {
      if (member is FieldDeclaration) {
        final type = member.fields.type?.toSource() ?? 'dynamic';
        for (final variable in member.fields.variables) {
          fields.add('$type ${variable.name.lexeme}');
        }
      }
    }

    if (fields.isEmpty) return;

    // Build the record typedef
    final recordDef = 'typedef $className = ({${fields.join(', ')}});';

    await builder.addDartFileEdit(file, (builder) {
      builder.addSimpleReplacement(
        SourceRange(classDecl.offset, classDecl.length),
        recordDef,
      );
    });
  }

  ClassDeclaration? _findClassDeclaration(AstNode? node) {
    if (node == null) return null;
    if (node is ClassDeclaration) return node;

    // Handle when node is the class name identifier
    if (node is SimpleIdentifier) {
      final parent = node.parent;
      if (parent is ClassDeclaration) return parent;
    }

    AstNode? current = node;
    while (current != null) {
      if (current is ClassDeclaration) return current;
      current = current.parent;
    }
    return null;
  }
}
