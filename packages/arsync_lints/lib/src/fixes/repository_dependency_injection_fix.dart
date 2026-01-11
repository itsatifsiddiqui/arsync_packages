import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';

/// Quick fix for `repository_dependency_injection` rule - convert to constructor injection.
///
/// Removes the field with direct instantiation and adds it as a constructor parameter.
/// Before:
/// ```dart
/// class AuthRepository {
///   final Dio _dio = Dio();
/// }
/// ```
/// After:
/// ```dart
/// class AuthRepository {
///   final Dio _dio;
///   AuthRepository(this._dio);
/// }
/// ```
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
    final fieldDecl = _findFieldDeclaration(node);
    if (fieldDecl == null) return;

    final classDecl = fieldDecl.parent;
    if (classDecl is! ClassDeclaration) return;

    // Get field info
    final fieldType = fieldDecl.fields.type?.toSource() ?? 'dynamic';
    final variables = fieldDecl.fields.variables;
    if (variables.isEmpty) return;

    final variable = variables.first;
    final fieldName = variable.name.lexeme;

    // Check if there's already a constructor
    ConstructorDeclaration? existingConstructor;
    for (final member in classDecl.members) {
      if (member is ConstructorDeclaration && member.name == null) {
        existingConstructor = member;
        break;
      }
    }

    // Build the new field declaration (without initializer)
    final newFieldDecl = 'final $fieldType $fieldName;';

    // Calculate line info for proper deletion
    final lineInfo = unitResult.lineInfo;
    final fieldLine = lineInfo.getLocation(fieldDecl.offset).lineNumber - 1;
    final lineStart = lineInfo.getOffsetOfLine(fieldLine);

    var lineEnd = fieldDecl.end;
    final content = unitResult.content;
    while (lineEnd < content.length && content[lineEnd] != '\n') {
      lineEnd++;
    }
    if (lineEnd < content.length && content[lineEnd] == '\n') {
      lineEnd++;
    }

    await builder.addDartFileEdit(file, (builder) {
      // Replace the field declaration
      builder.addSimpleReplacement(
        SourceRange(lineStart, lineEnd - lineStart),
        '  $newFieldDecl\n',
      );

      if (existingConstructor != null) {
        // Add to existing constructor
        final params = existingConstructor.parameters;
        if (params.parameters.isEmpty) {
          // Empty constructor - add parameter
          builder.addSimpleReplacement(
            SourceRange(params.leftParenthesis.end, 0),
            'this.$fieldName',
          );
        } else {
          // Add to existing parameters
          final lastParam = params.parameters.last;
          builder.addSimpleInsertion(lastParam.end, ', this.$fieldName');
        }
      } else {
        // Add a new constructor after the field
        final className = classDecl.name.lexeme;
        final constructorCode = '\n  $className(this.$fieldName);\n';

        // Insert after the field declaration
        builder.addSimpleInsertion(lineEnd, constructorCode);
      }
    });
  }

  FieldDeclaration? _findFieldDeclaration(AstNode? node) {
    if (node == null) return null;
    if (node is FieldDeclaration) return node;

    // Check if we're on the initializer (InstanceCreationExpression)
    if (node is InstanceCreationExpression) {
      AstNode? current = node;
      while (current != null) {
        if (current is FieldDeclaration) return current;
        current = current.parent;
      }
    }

    AstNode? current = node;
    while (current != null) {
      if (current is FieldDeclaration) return current;
      current = current.parent;
    }
    return null;
  }
}

/// Quick fix for `repository_dependency_injection` rule - remove Ref field.
///
/// Removes the entire Ref field declaration.
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
    final fieldDecl = _findFieldDeclaration(node);
    if (fieldDecl == null) return;

    // Check if this is a Ref field
    final typeAnnotation = fieldDecl.fields.type;
    if (typeAnnotation == null) return;

    final typeName = typeAnnotation.toSource();
    if (typeName != 'Ref' && !typeName.startsWith('Ref<')) return;

    // Get the full source range including any preceding newline
    var startOffset = fieldDecl.offset;
    var endOffset = fieldDecl.end;

    // Try to include the newline after
    final content = unitResult.content;
    if (endOffset < content.length && content[endOffset] == '\n') {
      endOffset++;
    }

    await builder.addDartFileEdit(file, (builder) {
      builder.addDeletion(SourceRange(startOffset, endOffset - startOffset));
    });
  }

  FieldDeclaration? _findFieldDeclaration(AstNode? node) {
    if (node == null) return null;
    if (node is FieldDeclaration) return node;

    AstNode? current = node;
    while (current != null) {
      if (current is FieldDeclaration) return current;
      current = current.parent;
    }
    return null;
  }
}
