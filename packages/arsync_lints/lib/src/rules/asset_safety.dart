import '../arsync_lint_rule.dart';

/// Rule E3: `Image.asset(...)`, `SvgPicture.asset(...)`, and `AssetImage(...)`
/// must use constants from a generated `Images.*` class (in
/// `lib/utils/images.dart`) rather than raw string literals.
class AssetSafety extends AnalysisRule {
  AssetSafety() : super(name: code.lowerCaseName, description: code.problemMessage);

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
    registry
      ..addInstanceCreationExpression(this, visitor)
      ..addMethodInvocation(this, visitor);
  }
}

class _Visitor extends ArsyncRuleVisitor<AnalysisRule> {
  _Visitor(super.rule);

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    final type = node.constructorName.type.name.lexeme;
    final ctor = node.constructorName.name?.name;
    if ((type == 'Image' && ctor == 'asset') ||
        (type == 'SvgPicture' && ctor == 'asset') ||
        type == 'AssetImage') {
      _checkFirstArgument(node.argumentList);
    }
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    final target = node.target;
    if (target is! SimpleIdentifier) return;
    if ((target.name == 'Image' || target.name == 'SvgPicture') &&
        node.methodName.name == 'asset') {
      _checkFirstArgument(node.argumentList);
    }
  }

  void _checkFirstArgument(ArgumentList list) {
    final first = list.arguments.firstOrNull;
    if (first is StringLiteral) {
      rule.reportAtNode(first);
    } else if (first is NamedExpression && first.expression is StringLiteral) {
      rule.reportAtNode(first.expression);
    }
  }
}
