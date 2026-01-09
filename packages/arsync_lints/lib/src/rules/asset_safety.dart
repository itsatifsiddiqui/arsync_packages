import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../utils.dart';

/// Rule E3: asset_safety
///
/// Prevent typos in asset paths.
/// Ban: String literals in Image.asset(), SvgPicture.asset()
/// Requirement: Must use Images.* from lib/utils/images.dart
class AssetSafety extends DartLintRule {
  const AssetSafety() : super(code: _code);

  static const _code = LintCode(
    name: 'asset_safety',
    problemMessage:
        'Asset paths must use constants from Images class, not string literals.',
    correctionMessage:
        'Replace the string literal with Images.yourAssetName from lib/utils/images.dart.',
  );

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

    context.registry.addInstanceCreationExpression((node) {
      _checkAssetCreation(node, reporter);
    });

    context.registry.addMethodInvocation((node) {
      _checkAssetMethodCall(node, reporter);
    });
  }

  void _checkAssetCreation(
      InstanceCreationExpression node, ErrorReporter reporter) {
    final typeName = node.constructorName.type.name2.lexeme;
    final constructorName = node.constructorName.name?.name;

    // Check for Image.asset
    if (typeName == 'Image' && constructorName == 'asset') {
      _checkFirstArgument(node.argumentList, reporter);
    }

    // Check for SvgPicture.asset
    if (typeName == 'SvgPicture' && constructorName == 'asset') {
      _checkFirstArgument(node.argumentList, reporter);
    }

    // Check for AssetImage
    if (typeName == 'AssetImage') {
      _checkFirstArgument(node.argumentList, reporter);
    }
  }

  void _checkAssetMethodCall(MethodInvocation node, ErrorReporter reporter) {
    final target = node.target;
    final methodName = node.methodName.name;

    // Check for Image.asset or SvgPicture.asset method calls
    if (target is SimpleIdentifier) {
      if ((target.name == 'Image' || target.name == 'SvgPicture') &&
          methodName == 'asset') {
        _checkFirstArgument(node.argumentList, reporter);
      }
    }
  }

  void _checkFirstArgument(ArgumentList argumentList, ErrorReporter reporter) {
    if (argumentList.arguments.isEmpty) return;

    final firstArg = argumentList.arguments.first;

    // Check if the first argument is a string literal
    if (firstArg is StringLiteral) {
      reporter.atNode(firstArg, _code);
    }

    // Also check if it's a named argument with a string literal
    if (firstArg is NamedExpression && firstArg.expression is StringLiteral) {
      reporter.atNode(firstArg.expression, _code);
    }
  }
}
