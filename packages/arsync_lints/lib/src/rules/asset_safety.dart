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

    // NOTE: We pass context.allUnits to the visitor because definingUnit.content
    // only returns the LIBRARY file content, not part file (.g.dart) content.
    final visitor = _Visitor(this, context.allUnits);
    registry.addInstanceCreationExpression(this, visitor);
    registry.addMethodInvocation(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AnalysisRule rule;
  final List<dynamic> allUnits;

  _Visitor(this.rule, this.allUnits);

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    // Skip generated files and nodes with ignore comments
    if (NodeContentHelper.shouldSkipNode(node, allUnits, rule.name)) return;

    final typeName = node.constructorName.type.name.lexeme;
    final constructorName = node.constructorName.name?.name;

    if (typeName == 'Image' && constructorName == 'asset') {
      _checkFirstArgument(node, node.argumentList);
    }
    if (typeName == 'SvgPicture' && constructorName == 'asset') {
      _checkFirstArgument(node, node.argumentList);
    }
    if (typeName == 'AssetImage') {
      _checkFirstArgument(node, node.argumentList);
    }
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    // Skip generated files and nodes with ignore comments
    if (NodeContentHelper.shouldSkipNode(node, allUnits, rule.name)) return;

    final target = node.target;
    final methodName = node.methodName.name;

    if (target is SimpleIdentifier) {
      if ((target.name == 'Image' || target.name == 'SvgPicture') &&
          methodName == 'asset') {
        _checkFirstArgument(node, node.argumentList);
      }
    }
  }

  void _checkFirstArgument(AstNode parentNode, ArgumentList argumentList) {
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
