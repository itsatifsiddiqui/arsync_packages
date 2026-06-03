import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import "../ast_extensions.dart";
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';

import 'fix_helpers.dart';

/// Quick fix for `presentation_layer_isolation` rule - remove banned import.
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
    final import = node.thisOrAncestorOfType<ImportDirective>();
    if (import == null) return;
    await FixHelpers.deleteLine(builder, unitResult, file, import);
  }
}

/// Quick fix for `presentation_layer_isolation` rule - convert class to record.
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
    final classDecl = node.thisOrAncestorOfType<ClassDeclaration>();
    if (classDecl == null) return;

    final fields = <String>[
      for (final m in classDecl.classMembers)
        if (m is FieldDeclaration)
          for (final v in m.fields.variables)
            '${m.fields.type?.toSource() ?? 'dynamic'} ${v.name.lexeme}',
    ];
    if (fields.isEmpty) return;

    final recordDef =
        'typedef ${classDecl.className.lexeme} = ({${fields.join(', ')}});';

    await builder.addDartFileEdit(file, (b) {
      b.addSimpleReplacement(
        SourceRange(classDecl.offset, classDecl.length),
        recordDef,
      );
    });
  }
}
