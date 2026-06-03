import '../arsync_lint_rule.dart';

/// Lint rule: two adjacent `SliverToBoxAdapter` widgets in a list literal —
/// consolidate them into a single `SliverList.list` instead.
class AvoidConsecutiveSliverToBoxAdapter extends AnalysisRule {
  AvoidConsecutiveSliverToBoxAdapter()
    : super(name: code.lowerCaseName, description: code.problemMessage);

  static const code = LintCode(
    'avoid_consecutive_sliver_to_box_adapter',
    'Avoid using consecutive SliverToBoxAdapter. '
        'Consider using SliverList.list instead.',
    correctionMessage:
        'Combine consecutive SliverToBoxAdapter widgets into a single '
        'SliverList.list for better performance.',
  );

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    registry.addListLiteral(this, _Visitor(this));
  }
}

class _Visitor extends ArsyncRuleVisitor<AnalysisRule> {
  _Visitor(super.rule);

  @override
  void visitListLiteral(ListLiteral node) {

    final elements = node.elements;
    for (var i = 1; i < elements.length; i++) {
      if (_usesSliverToBoxAdapter(elements[i - 1]) &&
          _usesSliverToBoxAdapter(elements[i])) {
        rule.reportAtNode(node);
        return;
      }
    }
  }

  static bool _usesSliverToBoxAdapter(CollectionElement el) {
    if (el is! InstanceCreationExpression) return false;
    if (el.typeName == 'SliverToBoxAdapter') return true;
    // Wrapped in another sliver via `sliver:` arg (e.g. SliverPadding).
    for (final a in el.argumentList.arguments) {
      if (a is NamedExpression &&
          a.name.label.name == 'sliver' &&
          a.expression is InstanceCreationExpression &&
          (a.expression as InstanceCreationExpression).typeName ==
              'SliverToBoxAdapter') {
        return true;
      }
    }
    return false;
  }
}
