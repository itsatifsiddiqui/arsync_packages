import '../arsync_lint_rule.dart';

/// Rule E3: asset_safety
///
/// Prevent typos in asset paths.
/// Ban: String literals in Image.asset(), SvgPicture.asset()
/// Requirement: Must use Images.* from lib/utils/images.dart
class AssetSafety extends AnalysisRule {
  AssetSafety()
      : super(
          name: 'asset_safety',
          description:
              'Asset paths must use constants from Images class, not string literals.',
        );

  static const LintCode code = LintCode(
    'asset_safety',
    'Asset paths must use constants from Images class, not string literals.',
    correctionMessage:
        'Replace the string literal with Images.yourAssetName from lib/utils/images.dart.',
  );

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    if (!context.isInLibDir) return;

    final visitor = _Visitor(this);
    registry.addInstanceCreationExpression(this, visitor);
    registry.addMethodInvocation(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AnalysisRule rule;

  _Visitor(this.rule);

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    final typeName = node.constructorName.type.name.lexeme;
    final constructorName = node.constructorName.name?.name;

    if (typeName == 'Image' && constructorName == 'asset') {
      _checkFirstArgument(node.argumentList);
    }
    if (typeName == 'SvgPicture' && constructorName == 'asset') {
      _checkFirstArgument(node.argumentList);
    }
    if (typeName == 'AssetImage') {
      _checkFirstArgument(node.argumentList);
    }
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    final target = node.target;
    final methodName = node.methodName.name;

    if (target is SimpleIdentifier) {
      if ((target.name == 'Image' || target.name == 'SvgPicture') &&
          methodName == 'asset') {
        _checkFirstArgument(node.argumentList);
      }
    }
  }

  void _checkFirstArgument(ArgumentList argumentList) {
    if (argumentList.arguments.isEmpty) return;

    final firstArg = argumentList.arguments.first;

    if (firstArg is StringLiteral) {
      rule.reportAtNode(firstArg);
    }

    if (firstArg is NamedExpression && firstArg.expression is StringLiteral) {
      rule.reportAtNode(firstArg.expression);
    }
  }
}
