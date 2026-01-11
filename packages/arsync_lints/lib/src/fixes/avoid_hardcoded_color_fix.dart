import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';

/// Quick fix for `avoid_hardcoded_color` rule.
///
/// Replaces hardcoded color with a placeholder Theme color.
class AvoidHardcodedColorFix extends ResolvedCorrectionProducer {
  AvoidHardcodedColorFix({required super.context});

  static const _fixKind = FixKind(
    'arsync.fix.avoidHardcodedColor',
    100,
    'Replace with Theme color',
  );

  @override
  FixKind? get fixKind => _fixKind;

  @override
  CorrectionApplicability get applicability =>
      CorrectionApplicability.singleLocation;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final colorNode = _findColorNode(node);
    if (colorNode == null) return;

    await builder.addDartFileEdit(file, (builder) {
      builder.addSimpleReplacement(
        SourceRange(colorNode.offset, colorNode.length),
        'Theme.of(context).colorScheme.primary',
      );
    });
  }

  AstNode? _findColorNode(AstNode? node) {
    if (node == null) return null;

    AstNode? current = node;
    while (current != null) {
      if (current is InstanceCreationExpression) {
        final typeName = current.staticType?.getDisplayString();
        if (typeName == 'Color' ||
            typeName == 'MaterialColor' ||
            typeName == 'MaterialAccentColor') {
          return current;
        }
      }
      if (current is MethodInvocation) {
        final methodName = current.methodName.name;
        if (methodName == 'fromARGB' ||
            methodName == 'fromRGBO' ||
            methodName == 'alphaBlend' ||
            methodName == 'lerp') {
          return current;
        }
      }
      if (current is PrefixedIdentifier) {
        final prefix = current.prefix.name;
        if (prefix == 'Colors') {
          return current;
        }
      }
      current = current.parent;
    }
    return null;
  }
}
