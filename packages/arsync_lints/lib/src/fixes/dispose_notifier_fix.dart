import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import "../ast_extensions.dart";
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';

import 'fix_helpers.dart';

/// Add a new `dispose()` method that calls `<field>.dispose(); super.dispose();`.
class AddDisposeMethodFix extends ResolvedCorrectionProducer {
  AddDisposeMethodFix({required super.context});

  static const _fixKind = FixKind(
    'arsync.fix.addDisposeMethod',
    50,
    'Add dispose() method',
  );

  @override
  FixKind get fixKind => _fixKind;

  @override
  CorrectionApplicability get applicability =>
      CorrectionApplicability.acrossSingleFile;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final node = this.node;
    if (node is! VariableDeclaration) return;

    final classDecl = node.thisOrAncestorOfType<ClassDeclaration>();
    if (classDecl == null) return;
    final hasDispose = classDecl.classMembers.any(
      (m) => m is MethodDeclaration && m.name.lexeme == 'dispose',
    );
    if (hasDispose) return;

    final last = classDecl.classMembers.lastOrNull;
    if (last == null) return;

    final fieldName = node.name.lexeme;
    await builder.addDartFileEdit(file, (b) {
      b.addInsertion(last.end, (w) {
        w
          ..writeln()
          ..writeln()
          ..writeln('  @override')
          ..writeln('  void dispose() {')
          ..writeln('    $fieldName.dispose();')
          ..writeln('    super.dispose();')
          ..write('  }');
      });
    });
  }
}

/// Add `<field>.dispose();` to an existing `dispose()` method.
class AddDisposeCallFix extends ResolvedCorrectionProducer {
  AddDisposeCallFix({required super.context});

  String? _fieldName;

  static const _fixKind = FixKind(
    'arsync.fix.addDisposeCall',
    51,
    "Add '.dispose()' call",
  );

  @override
  FixKind get fixKind => _fixKind;

  @override
  CorrectionApplicability get applicability =>
      CorrectionApplicability.acrossSingleFile;

  @override
  List<String> get fixArguments => [_fieldName ?? ''];

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final node = this.node;
    if (node is! VariableDeclaration) return;
    _fieldName = node.name.lexeme;

    final classDecl = node.thisOrAncestorOfType<ClassDeclaration>();
    if (classDecl == null) return;
    final dispose = classDecl.classMembers
        .whereType<MethodDeclaration>()
        .where((m) => m.name.lexeme == 'dispose')
        .firstOrNull;
    final body = dispose?.body;
    if (body is! BlockFunctionBody) return;

    final block = body.block;
    final superDispose = block.statements
        .whereType<ExpressionStatement>()
        .where((s) {
          final e = s.expression;
          return e is MethodInvocation &&
              e.methodName.name == 'dispose' &&
              e.target is SuperExpression;
        })
        .firstOrNull;

    await builder.addDartFileEdit(file, (b) {
      if (superDispose != null) {
        final indent = FixHelpers.indentOf(unitResult,superDispose.offset);
        b.addInsertion(superDispose.offset, (w) {
          w
            ..write('$_fieldName.dispose();')
            ..writeln()
            ..write(indent);
        });
      } else if (block.statements.isNotEmpty) {
        final last = block.statements.last;
        final indent = FixHelpers.indentOf(unitResult,last.offset);
        b.addInsertion(last.end, (w) {
          w
            ..writeln()
            ..write('$indent$_fieldName.dispose();');
        });
      } else {
        final braceIndent = FixHelpers.indentOf(unitResult,block.rightBracket.offset);
        b.addInsertion(block.rightBracket.offset, (w) {
          w
            ..write('$braceIndent  $_fieldName.dispose();')
            ..writeln();
        });
      }
    });
  }

}
