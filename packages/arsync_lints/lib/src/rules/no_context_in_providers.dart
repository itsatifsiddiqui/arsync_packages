import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../utils.dart';

/// Rule B3: no_context_in_providers
///
/// ViewModels must be UI-agnostic. BuildContext cannot be used as a parameter.
class NoContextInProviders extends DartLintRule {
  const NoContextInProviders() : super(code: _code);

  static const _code = LintCode(
    name: 'no_context_in_providers',
    problemMessage:
        'BuildContext cannot be used in providers. ViewModels must be UI-agnostic.',
    correctionMessage:
        'Remove BuildContext parameter.',
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    // Only apply to files in lib/providers/
    if (!PathUtils.isInProviders(resolver.path)) {
      return;
    }

    // Check function parameters
    context.registry.addFunctionDeclaration((node) {
      _checkParameters(node.functionExpression.parameters, reporter);
    });

    // Check method parameters
    context.registry.addMethodDeclaration((node) {
      _checkParameters(node.parameters, reporter);
    });

    // Check constructor parameters
    context.registry.addConstructorDeclaration((node) {
      _checkParameters(node.parameters, reporter);
    });
  }

  void _checkParameters(FormalParameterList? parameters, ErrorReporter reporter) {
    if (parameters == null) return;

    for (final param in parameters.parameters) {
      final typeName = _getParameterTypeName(param);
      if (typeName == 'BuildContext') {
        reporter.atNode(param, _code);
      }
    }
  }

  String? _getParameterTypeName(FormalParameter param) {
    if (param is SimpleFormalParameter) {
      final type = param.type;
      if (type is NamedType) {
        return type.name2.lexeme;
      }
    } else if (param is DefaultFormalParameter) {
      return _getParameterTypeName(param.parameter);
    }
    return null;
  }
}
