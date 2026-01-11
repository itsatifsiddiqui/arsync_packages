import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';

/// Quick fix for `scaffold_location` rule.
///
/// Replaces Scaffold with Container in widgets folder:
/// - Before: `Scaffold(body: child)`
/// - After: `Container(child: child)`
class ScaffoldLocationFix extends ResolvedCorrectionProducer {
  ScaffoldLocationFix({required super.context});

  static const _fixKind = FixKind(
    'arsync.fix.scaffoldLocation',
    100,
    'Replace with Container',
  );

  @override
  FixKind? get fixKind => _fixKind;

  @override
  CorrectionApplicability get applicability =>
      CorrectionApplicability.singleLocation;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final creation = _findScaffoldCreation(node);
    if (creation == null) return;

    // Get the body argument if it exists
    final args = creation.argumentList.arguments;
    Expression? bodyArg;
    for (final arg in args) {
      if (arg is NamedExpression && arg.name.label.name == 'body') {
        bodyArg = arg.expression;
        break;
      }
    }

    // Build replacement Container
    String replacement;
    if (bodyArg != null) {
      replacement = 'Container(child: ${bodyArg.toSource()})';
    } else {
      replacement = 'Container()';
    }

    await builder.addDartFileEdit(file, (builder) {
      builder.addSimpleReplacement(
        SourceRange(creation.offset, creation.length),
        replacement,
      );
    });
  }

  InstanceCreationExpression? _findScaffoldCreation(AstNode? node) {
    if (node == null) return null;

    if (node is InstanceCreationExpression) {
      final typeName = node.constructorName.type.name.lexeme;
      if (typeName == 'Scaffold') return node;
    }

    AstNode? current = node;
    while (current != null) {
      if (current is InstanceCreationExpression) {
        final typeName = current.constructorName.type.name.lexeme;
        if (typeName == 'Scaffold') return current;
      }
      current = current.parent;
    }
    return null;
  }
}
