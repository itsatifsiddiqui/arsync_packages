import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import "../ast_extensions.dart";
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';

import 'fix_helpers.dart';

/// Add a matching `removeListener` / `removeStatusListener` call to `dispose()`
/// (creating the method if it doesn't exist).
class AddRemoveListenerCallFix extends ResolvedCorrectionProducer {
  AddRemoveListenerCallFix({required super.context});

  static const _fixKind = FixKind(
    'arsync.fix.addRemoveListenerCall',
    50,
    "Add 'removeListener' call to dispose()",
  );

  @override
  FixKind get fixKind => _fixKind;

  @override
  CorrectionApplicability get applicability =>
      CorrectionApplicability.acrossSingleFile;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final node = this.node;
    if (node is! MethodInvocation) return;

    final method = node.methodName.name;
    if (method != 'addListener' && method != 'addStatusListener') return;

    final args = node.argumentList.arguments;
    if (args.isEmpty) return;

    final callbackName = _identifierName(args.first);
    final targetStr = _targetString(node.target);
    if (callbackName == null || targetStr == null) return;

    final removeMethod =
        method == 'addStatusListener' ? 'removeStatusListener' : 'removeListener';
    final newStmt = '$targetStr.$removeMethod($callbackName);';

    final classDecl = node.thisOrAncestorOfType<ClassDeclaration>();
    if (classDecl == null) return;
    final dispose = classDecl.classMembers
        .whereType<MethodDeclaration>()
        .where((m) => m.name.lexeme == 'dispose')
        .firstOrNull;

    if (dispose == null) {
      final last = classDecl.classMembers.lastOrNull;
      if (last == null) return;
      await builder.addDartFileEdit(file, (b) {
        b.addInsertion(last.end, (w) {
          w
            ..writeln()
            ..writeln()
            ..writeln('  @override')
            ..writeln('  void dispose() {')
            ..writeln('    $newStmt')
            ..writeln('    super.dispose();')
            ..write('  }');
        });
      });
      return;
    }

    final body = dispose.body;
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
        final indent = FixHelpers.indentOf(unitResult, superDispose.offset);
        b.addInsertion(superDispose.offset, (w) {
          w
            ..write(newStmt)
            ..writeln()
            ..write(indent);
        });
      } else if (block.statements.isNotEmpty) {
        final last = block.statements.last;
        final indent = FixHelpers.indentOf(unitResult, last.offset);
        b.addInsertion(last.end, (w) {
          w
            ..writeln()
            ..write('$indent$newStmt');
        });
      } else {
        final braceIndent = FixHelpers.indentOf(unitResult, block.rightBracket.offset);
        b.addInsertion(block.rightBracket.offset, (w) {
          w
            ..write('$braceIndent  $newStmt')
            ..writeln();
        });
      }
    });
  }

  String? _identifierName(Expression e) {
    if (e is SimpleIdentifier) return e.name;
    if (e is PrefixedIdentifier) return e.identifier.name;
    return null;
  }

  String? _targetString(Expression? target) {
    if (target == null) return null;
    if (target is SimpleIdentifier) return target.name;
    if (target is PrefixedIdentifier) {
      return '${target.prefix.name}.${target.identifier.name}';
    }
    if (target is PropertyAccess) {
      final prefix = _targetString(target.target);
      return prefix == null ? null : '$prefix.${target.propertyName.name}';
    }
    return null;
  }
}
