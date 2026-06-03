import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import "../ast_extensions.dart";
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';

/// Quick fix for `repository_dependency_injection` — convert a field with
/// direct instantiation to constructor injection.
class RepositoryDependencyInjectionFix extends ResolvedCorrectionProducer {
  RepositoryDependencyInjectionFix({required super.context});

  static const _fixKind = FixKind(
    'arsync.fix.repositoryDependencyInjection',
    100,
    'Convert to constructor injection',
  );

  @override
  FixKind? get fixKind => _fixKind;

  @override
  CorrectionApplicability get applicability =>
      CorrectionApplicability.singleLocation;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final field = node.thisOrAncestorOfType<FieldDeclaration>();
    final classDecl = field?.parent;
    if (field == null || classDecl is! ClassDeclaration) return;

    if (field.fields.variables.isEmpty) return;
    final fieldName = field.fields.variables.first.name.lexeme;
    final fieldType = field.fields.type?.toSource() ?? 'dynamic';

    final constructor = classDecl.classMembers
        .whereType<ConstructorDeclaration>()
        .where((c) => c.name == null)
        .firstOrNull;

    final lineInfo = unitResult.lineInfo;
    final fieldLine = lineInfo.getLocation(field.offset).lineNumber - 1;
    final lineStart = lineInfo.getOffsetOfLine(fieldLine);
    final content = unitResult.content;
    var lineEnd = field.end;
    while (lineEnd < content.length && content[lineEnd] != '\n') {
      lineEnd++;
    }
    if (lineEnd < content.length && content[lineEnd] == '\n') lineEnd++;

    await builder.addDartFileEdit(file, (b) {
      b.addSimpleReplacement(
        SourceRange(lineStart, lineEnd - lineStart),
        '  final $fieldType $fieldName;\n',
      );
      if (constructor != null) {
        final params = constructor.parameters;
        if (params.parameters.isEmpty) {
          b.addSimpleReplacement(
            SourceRange(params.leftParenthesis.end, 0),
            'this.$fieldName',
          );
        } else {
          b.addSimpleInsertion(
            params.parameters.last.end,
            ', this.$fieldName',
          );
        }
      } else {
        b.addSimpleInsertion(
          lineEnd,
          '\n  ${classDecl.className.lexeme}(this.$fieldName);\n',
        );
      }
    });
  }
}

/// Quick fix for `repository_dependency_injection` — delete a `Ref` field.
class RepositoryDependencyInjectionRemoveRefFix
    extends ResolvedCorrectionProducer {
  RepositoryDependencyInjectionRemoveRefFix({required super.context});

  static const _fixKind = FixKind(
    'arsync.fix.repositoryDependencyInjectionRemoveRef',
    100,
    'Remove Ref field (not allowed in repositories)',
  );

  @override
  FixKind? get fixKind => _fixKind;

  @override
  CorrectionApplicability get applicability =>
      CorrectionApplicability.singleLocation;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final field = node.thisOrAncestorOfType<FieldDeclaration>();
    final type = field?.fields.type?.toSource();
    if (field == null ||
        type == null ||
        (type != 'Ref' && !type.startsWith('Ref<'))) {
      return;
    }

    var end = field.end;
    final content = unitResult.content;
    if (end < content.length && content[end] == '\n') end++;

    await builder.addDartFileEdit(file, (b) {
      b.addDeletion(SourceRange(field.offset, end - field.offset));
    });
  }
}
