import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';

/// Quick fix for `shared_widget_purity` rule - remove banned import.
///
/// Removes the provider/riverpod import that violates widget purity.
class SharedWidgetPurityImportFix extends ResolvedCorrectionProducer {
  SharedWidgetPurityImportFix({required super.context});

  static const _fixKind = FixKind(
    'arsync.fix.sharedWidgetPurityImport',
    100,
    'Remove provider import',
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

    // Remove the entire import line
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

/// Quick fix for `shared_widget_purity` rule - make widget private.
///
/// Adds underscore prefix to make the widget class private.
class SharedWidgetPurityMakePrivateFix extends ResolvedCorrectionProducer {
  SharedWidgetPurityMakePrivateFix({required super.context});

  static const _fixKind = FixKind(
    'arsync.fix.sharedWidgetPurityMakePrivate',
    100,
    'Make widget private with _ prefix',
  );

  @override
  FixKind? get fixKind => _fixKind;

  @override
  CorrectionApplicability get applicability =>
      CorrectionApplicability.singleLocation;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final classNameToken = _findClassNameToken(node);
    if (classNameToken == null) return;

    final currentName = classNameToken.lexeme;
    if (currentName.startsWith('_')) return;

    final newName = '_$currentName';

    await builder.addDartFileEdit(file, (builder) {
      builder.addSimpleReplacement(
        SourceRange(classNameToken.offset, classNameToken.length),
        newName,
      );
    });
  }

  Token? _findClassNameToken(AstNode? node) {
    if (node == null) return null;

    if (node is ClassDeclaration) {
      return node.name;
    }

    if (node is SimpleIdentifier) {
      final parent = node.parent;
      if (parent is ClassDeclaration) {
        return parent.name;
      }
    }

    AstNode? current = node;
    while (current != null) {
      if (current is ClassDeclaration) {
        return current.name;
      }
      current = current.parent;
    }
    return null;
  }
}
