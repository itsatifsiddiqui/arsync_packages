import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';

import '../utils.dart';

/// Quick fix for `model_purity` rule - remove banned import.
class ModelPurityImportFix extends ResolvedCorrectionProducer {
  ModelPurityImportFix({required super.context});

  static const _fixKind = FixKind(
    'arsync.fix.modelPurityImport',
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

/// Quick fix for `model_purity` rule - convert to Freezed class.
///
/// Converts a plain class to a full Freezed class with:
/// - @freezed annotation
/// - sealed class with _$ClassName mixin
/// - const factory constructor
/// - part directives
class ModelPurityAddFreezedFix extends ResolvedCorrectionProducer {
  ModelPurityAddFreezedFix({required super.context});

  static const _fixKind = FixKind(
    'arsync.fix.modelPurityAddFreezed',
    100,
    'Convert to Freezed class',
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

    // Check if already has @freezed
    final hasFreezed = classDecl.metadata.any((a) =>
        a.name.name == 'freezed' || a.name.name == 'Freezed');
    if (hasFreezed) return;

    final className = classDecl.name.lexeme;
    final fileName = PathUtils.getFileName(unitResult.path);

    // Extract fields from the class
    final fields = <_FieldInfo>[];
    for (final member in classDecl.members) {
      if (member is FieldDeclaration) {
        final type = member.fields.type?.toSource() ?? 'dynamic';
        for (final variable in member.fields.variables) {
          final fieldName = variable.name.lexeme;
          final hasDefault = variable.initializer != null;
          final defaultValue = variable.initializer?.toSource();
          final isNullable = type.endsWith('?');
          fields.add(_FieldInfo(
            name: fieldName,
            type: type,
            isRequired: !isNullable && !hasDefault,
            hasDefault: hasDefault,
            defaultValue: defaultValue,
          ));
        }
      }
    }

    // Build factory parameters
    final params = fields.map((f) {
      if (f.hasDefault && f.defaultValue != null) {
        return '@Default(${f.defaultValue}) ${f.type} ${f.name}';
      } else if (f.isRequired) {
        return 'required ${f.type} ${f.name}';
      } else {
        return '${f.type} ${f.name}';
      }
    }).join(',\n    ');

    // Build the new Freezed class
    final freezedClass = '''@freezed
sealed class $className with _\$$className {
  const factory $className({
    $params,
  }) = _$className;

  factory $className.fromJson(Map<String, dynamic> json) =>
      _\$${className}FromJson(json);
}''';

    // Check if part directives exist
    final unit = unitResult.unit;
    final hasFreezedPart = unit.directives.any((d) =>
        d is PartDirective && d.uri.stringValue?.contains('.freezed.dart') == true);
    final hasGPart = unit.directives.any((d) =>
        d is PartDirective && d.uri.stringValue?.contains('.g.dart') == true);

    // Find where to insert part directives (after imports)
    var partInsertOffset = 0;
    for (final directive in unit.directives) {
      if (directive is ImportDirective) {
        partInsertOffset = directive.end;
      }
    }

    // Build part directives if needed
    var partDirectives = '';
    if (!hasFreezedPart || !hasGPart) {
      partDirectives = '\n';
      if (!hasFreezedPart) {
        partDirectives += "\npart '$fileName.freezed.dart';";
      }
      if (!hasGPart) {
        partDirectives += "\npart '$fileName.g.dart';";
      }
    }

    await builder.addDartFileEdit(file, (builder) {
      // Add part directives if needed
      if (partDirectives.isNotEmpty && partInsertOffset > 0) {
        builder.addSimpleInsertion(partInsertOffset, partDirectives);
      }

      // Replace the class
      builder.addSimpleReplacement(
        SourceRange(classDecl.offset, classDecl.length),
        freezedClass,
      );
    });
  }

  ClassDeclaration? _findClassDeclaration(AstNode? node) {
    if (node == null) return null;
    if (node is ClassDeclaration) return node;

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

class _FieldInfo {
  final String name;
  final String type;
  final bool isRequired;
  final bool hasDefault;
  final String? defaultValue;

  _FieldInfo({
    required this.name,
    required this.type,
    required this.isRequired,
    required this.hasDefault,
    this.defaultValue,
  });
}

/// Quick fix for `model_purity` rule - add fromJson factory.
class ModelPurityAddFromJsonFix extends ResolvedCorrectionProducer {
  ModelPurityAddFromJsonFix({required super.context});

  static const _fixKind = FixKind(
    'arsync.fix.modelPurityAddFromJson',
    100,
    'Add fromJson factory constructor',
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

    // Check if already has fromJson
    final hasFromJson = classDecl.members.any((member) {
      if (member is ConstructorDeclaration) {
        return member.factoryKeyword != null && member.name?.lexeme == 'fromJson';
      }
      return false;
    });
    if (hasFromJson) return;

    // Find the position to insert (after the last member or at the start of body)
    final insertOffset = classDecl.rightBracket.offset;

    // Generate fromJson factory
    final fromJsonCode = '''

  factory $className.fromJson(Map<String, dynamic> json) => _\$${className}FromJson(json);
''';

    await builder.addDartFileEdit(file, (builder) {
      builder.addSimpleInsertion(insertOffset, fromJsonCode);
    });
  }

  ClassDeclaration? _findClassDeclaration(AstNode? node) {
    if (node == null) return null;
    if (node is ClassDeclaration) return node;

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
