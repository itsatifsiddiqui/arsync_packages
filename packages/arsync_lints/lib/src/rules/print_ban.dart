import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../utils.dart';

/// Rule D3: print_ban
///
/// Production apps should not spam the console.
/// Banned: print(), debugPrint()
class PrintBan extends DartLintRule {
  const PrintBan() : super(code: _code);

  static const _code = LintCode(
    name: 'print_ban',
    problemMessage:
        'print() and debugPrint() are banned. Use .log() extension instead.',
    correctionMessage: 'Replace with your custom logging extension (.log()).',
  );

  static const _bannedFunctions = ['print', 'debugPrint'];

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    // Only apply to lib/ files
    if (!PathUtils.isInLib(resolver.path)) {
      return;
    }

    context.registry.addMethodInvocation((node) {
      final methodName = node.methodName.name;

      if (_bannedFunctions.contains(methodName)) {
        // Make sure it's a top-level function call, not a method on an object
        if (node.target == null) {
          reporter.atNode(node, _code);
        }
      }
    });

    // Also check for function expression invocations (standalone function calls)
    context.registry.addFunctionExpressionInvocation((node) {
      final function = node.function;
      if (function is SimpleIdentifier) {
        if (_bannedFunctions.contains(function.name)) {
          reporter.atNode(node, _code);
        }
      }
    });
  }
}
