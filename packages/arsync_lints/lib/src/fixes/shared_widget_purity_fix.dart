import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import "../ast_extensions.dart";
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';

import 'fix_helpers.dart';

/// Quick fix for `shared_widget_purity` rule - remove banned import.
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
    final import = node.thisOrAncestorOfType<ImportDirective>();
    if (import == null) return;
    await FixHelpers.deleteLine(builder, unitResult, file, import);
  }
}

/// Quick fix for `shared_widget_purity` rule - make widget private.
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
    final name = node.thisOrAncestorOfType<ClassDeclaration>()?.className;
    if (name == null || name.lexeme.startsWith('_')) return;

    await builder.addDartFileEdit(file, (b) {
      b.addSimpleReplacement(
        SourceRange(name.offset, name.length),
        '_${name.lexeme}',
      );
    });
  }
}
