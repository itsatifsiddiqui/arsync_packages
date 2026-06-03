import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import "../ast_extensions.dart";
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';

import '../utils.dart';
import 'fix_helpers.dart';

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
    final import = node.thisOrAncestorOfType<ImportDirective>();
    if (import == null) return;
    await FixHelpers.deleteLine(builder, unitResult, file, import);
  }
}

/// Quick fix for `model_purity` rule - convert to Freezed class.
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
    final classDecl = node.thisOrAncestorOfType<ClassDeclaration>();
    if (classDecl == null) return;

    final hasFreezed = classDecl.metadata.any(
      (a) => a.name.name == 'freezed' || a.name.name == 'Freezed',
    );
    if (hasFreezed) return;

    final className = classDecl.className.lexeme;
    final fileName = PathUtils.getFileName(unitResult.path);

    final params = <String>[];
    for (final m in classDecl.classMembers) {
      if (m is! FieldDeclaration) continue;
      final type = m.fields.type?.toSource() ?? 'dynamic';
      for (final v in m.fields.variables) {
        final name = v.name.lexeme;
        final init = v.initializer?.toSource();
        if (init != null) {
          params.add('@Default($init) $type $name');
        } else if (type.endsWith('?')) {
          params.add('$type $name');
        } else {
          params.add('required $type $name');
        }
      }
    }

    final freezedClass =
        '''@freezed
sealed class $className with _\$$className {
  const factory $className({
    ${params.join(',\n    ')},
  }) = _$className;

  factory $className.fromJson(Map<String, dynamic> json) =>
      _\$${className}FromJson(json);
}''';

    final unit = unitResult.unit;
    final hasFreezedPart = unit.directives.any(
      (d) =>
          d is PartDirective &&
          d.uri.stringValue?.contains('.freezed.dart') == true,
    );
    final hasGPart = unit.directives.any(
      (d) =>
          d is PartDirective && d.uri.stringValue?.contains('.g.dart') == true,
    );

    var partInsertOffset = 0;
    for (final d in unit.directives) {
      if (d is ImportDirective) partInsertOffset = d.end;
    }

    final parts = StringBuffer();
    if (!hasFreezedPart) parts.write("\npart '$fileName.freezed.dart';");
    if (!hasGPart) parts.write("\npart '$fileName.g.dart';");

    await builder.addDartFileEdit(file, (b) {
      if (parts.isNotEmpty && partInsertOffset > 0) {
        b.addSimpleInsertion(partInsertOffset, '\n$parts');
      }
      b.addSimpleReplacement(
        SourceRange(classDecl.offset, classDecl.length),
        freezedClass,
      );
    });
  }
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
    final classDecl = node.thisOrAncestorOfType<ClassDeclaration>();
    if (classDecl == null) return;

    final className = classDecl.className.lexeme;
    final hasFromJson = classDecl.classMembers.any(
      (m) =>
          m is ConstructorDeclaration &&
          m.factoryKeyword != null &&
          m.name?.lexeme == 'fromJson',
    );
    if (hasFromJson) return;

    await builder.addDartFileEdit(file, (b) {
      b.addSimpleInsertion(
        classDecl.bodyRightBracket.offset,
        '\n  factory $className.fromJson(Map<String, dynamic> json) => _\$${className}FromJson(json);\n',
      );
    });
  }
}
