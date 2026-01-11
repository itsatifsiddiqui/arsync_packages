import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';

/// Quick fix for `global_variable_restriction` rule.
///
/// Makes top-level variables and functions private by adding underscore prefix:
/// - Before: `String globalVar = 'value';`
/// - After: `String _globalVar = 'value';`
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
    // Find the token that was flagged
    final tokenInfo = _findNameToken(node);
    if (tokenInfo == null) return;

    final name = tokenInfo.lexeme;
    if (name.startsWith('_')) return; // Already private

    final newName = '_$name';

    await builder.addDartFileEdit(file, (builder) {
      builder.addSimpleReplacement(
        SourceRange(tokenInfo.offset, tokenInfo.length),
        newName,
      );
    });
  }

  Token? _findNameToken(AstNode? node) {
    if (node == null) return null;

    // Check if we're at a variable declaration
    if (node is VariableDeclaration) {
      return node.name;
    }

    // Check if we're at a function declaration
    if (node is FunctionDeclaration) {
      return node.name;
    }

    // Check if node itself is an identifier
    if (node is SimpleIdentifier) {
      return node.token;
    }

    // Traverse up to find the declaration
    AstNode? current = node;
    while (current != null) {
      if (current is VariableDeclaration) {
        return current.name;
      }
      if (current is FunctionDeclaration) {
        return current.name;
      }
      current = current.parent;
    }

    return null;
  }
}
