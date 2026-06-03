import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';

/// Quick fix for `global_variable_restriction` — prefix top-level name with `_`.
class GlobalVariableRestrictionFix extends ResolvedCorrectionProducer {
  GlobalVariableRestrictionFix({required super.context});

  static const _fixKind = FixKind(
    'arsync.fix.globalVariableRestriction',
    100,
    'Make private with _ prefix',
  );

  @override
  FixKind? get fixKind => _fixKind;

  @override
  CorrectionApplicability get applicability =>
      CorrectionApplicability.singleLocation;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final n = node;
    final Token? name;
    if (n is SimpleIdentifier) {
      name = n.token;
    } else {
      final decl = n.thisOrAncestorMatching(
        (a) => a is VariableDeclaration || a is FunctionDeclaration,
      );
      name = decl is VariableDeclaration
          ? decl.name
          : decl is FunctionDeclaration
          ? decl.name
          : null;
    }
    final n2 = name;
    if (n2 == null || n2.lexeme.startsWith('_')) return;

    await builder.addDartFileEdit(file, (b) {
      b.addSimpleReplacement(
        SourceRange(n2.offset, n2.length),
        '_${n2.lexeme}',
      );
    });
  }
}
