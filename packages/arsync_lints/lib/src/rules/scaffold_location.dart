import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../utils.dart';

/// Rule E2: scaffold_location
///
/// Pages live in screens; Fragments live in widgets.
/// Ban: Scaffold inside lib/widgets/
class ScaffoldLocation extends DartLintRule {
  const ScaffoldLocation() : super(code: _code);

  static const _code = LintCode(
    name: 'scaffold_location',
    problemMessage:
        'Scaffold is not allowed in widgets folder. Widgets should be fragments, not pages.',
    correctionMessage:
        'Use Container, Column, or a custom card widget instead of Scaffold.',
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    // Only apply to files in lib/widgets/
    if (!PathUtils.isInWidgets(resolver.path)) {
      return;
    }

    context.registry.addInstanceCreationExpression((node) {
      final typeName = node.constructorName.type.name2.lexeme;

      if (typeName == 'Scaffold') {
        reporter.atNode(node, _code);
      }
    });

    // Also check for Scaffold used as a function-like widget
    context.registry.addMethodInvocation((node) {
      if (node.methodName.name == 'Scaffold') {
        reporter.atNode(node, _code);
      }
    });
  }
}
