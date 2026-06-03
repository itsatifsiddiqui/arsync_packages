import '../arsync_lint_rule.dart';

/// Lint rule: a `Container(child: ...)` that uses none of `Container`'s
/// painting/positioning/sizing properties is unnecessary; use the child
/// directly.
class UnnecessaryContainer extends AnalysisRule {
  UnnecessaryContainer()
    : super(name: code.lowerCaseName, description: code.problemMessage);

  static const code = LintCode(
    'unnecessary_container',
    'Unnecessary Container widget.',
    correctionMessage:
        'Remove the Container and use the child directly, or add Container-specific properties.',
  );

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    registry.addInstanceCreationExpression(
      this,
      _Visitor(this),
    );
  }
}

class _Visitor extends ArsyncRuleVisitor<AnalysisRule> {
  _Visitor(super.rule);

  static const _meaningful = {
    'color',
    'decoration',
    'foregroundDecoration',
    'width',
    'height',
    'constraints',
    'margin',
    'padding',
    'alignment',
    'transform',
    'transformAlignment',
  };

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    if (node.typeName != 'Container') return;

    var hasChild = false;
    for (final arg in node.argumentList.arguments) {
      if (arg is! NamedExpression) continue;
      final name = arg.name.label.name;
      if (name == 'child') {
        hasChild = true;
      } else if (_meaningful.contains(name)) {
        return;
      } else if (name == 'clipBehavior' && _isMeaningfulClip(arg.expression)) {
        return;
      }
    }
    if (hasChild) rule.reportAtNode(node);
  }

  /// `clipBehavior` is meaningful unless explicitly set to `Clip.none`.
  static bool _isMeaningfulClip(Expression value) {
    if (value is PrefixedIdentifier) return value.identifier.name != 'none';
    if (value is PropertyAccess) return value.propertyName.name != 'none';
    return true;
  }
}
