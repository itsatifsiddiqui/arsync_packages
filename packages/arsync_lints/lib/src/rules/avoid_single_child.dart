import '../arsync_lint_rule.dart';

/// Lint rule discouraging multi-child layout widgets (`Column`, `Row`, `Stack`,
/// `Flex`, `Wrap`, `ListView`, `SliverList`, `SliverMainAxisGroup`,
/// `SliverCrossAxisGroup`) when they only contain a single static child.
///
/// `for`-elements and spreads are allowed since they may produce multiple
/// children at runtime.
class AvoidSingleChild extends AnalysisRule {
  AvoidSingleChild() : super(name: code.lowerCaseName, description: code.problemMessage);

  static const code = LintCode(
    'avoid_single_child',
    'Avoid using a single child in widgets that expect multiple children.',
    correctionMessage:
        'Consider using a single child widget or adding more children.',
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

  static const _multiChildWidgets = {
    'Column',
    'Row',
    'Flex',
    'Wrap',
    'Stack',
    'ListView',
    'SliverList',
    'SliverMainAxisGroup',
    'SliverCrossAxisGroup',
  };

  static const _childrenArgNames = {'children', 'slivers'};

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    if (!_multiChildWidgets.contains(node.typeName)) return;

    final arg = node.argumentList.arguments
        .whereType<NamedExpression>()
        .where((a) => _childrenArgNames.contains(a.name.label.name))
        .firstOrNull;
    final list = arg?.expression;
    if (list is! ListLiteral || list.elements.length != 1) return;

    // Allow `if` branches with multi-children, `for`, and spreads — any of
    // these can produce more than one child at runtime.
    final first = list.elements.first;
    if (first is ForElement || first is SpreadElement) return;
    if (first is IfElement) {
      if (_hasMultipleChildren(first.thenElement)) return;
      final e = first.elseElement;
      if (e != null && _hasMultipleChildren(e)) return;
    }

    rule.reportAtNode(node);
  }

  static bool _hasMultipleChildren(CollectionElement e) {
    if (e is SpreadElement && e.expression is ListLiteral) {
      return (e.expression as ListLiteral).elements.length > 1;
    }
    return false;
  }
}
