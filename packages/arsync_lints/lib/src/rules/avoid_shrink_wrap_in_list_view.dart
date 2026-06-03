import '../arsync_lint_rule.dart';

/// Lint rule: `ListView(shrinkWrap: true, ...)` inside another scrollable
/// (`ListView`/`Column`/`Row`) is a performance footgun — prefer slivers.
class AvoidShrinkWrapInListView extends AnalysisRule {
  AvoidShrinkWrapInListView()
    : super(name: code.lowerCaseName, description: code.problemMessage);

  static const code = LintCode(
    'avoid_shrink_wrap_in_list_view',
    'Avoid using ListView with shrinkWrap, '
        'since it might degrade the performance.',
    correctionMessage:
        'You can avoid shrink wrapping with the following 3 steps if your scroll view is nested:'
        'Replace the parent scroll view with CustomScrollView.'
        'Replace the child scroll view with SliverListView or SliverGridView.'
        'Set SliverChildBuilderDelegate to delegate argument of the SliverListView or SliverGridView.',
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

  static const _scrollableParents = {'ListView', 'Column', 'Row'};

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    if (node.typeName != 'ListView') return;
    if (!_hasShrinkWrap(node) || !_hasParentList(node)) return;
    rule.reportAtNode(node);
  }

  static bool _hasShrinkWrap(InstanceCreationExpression node) {
    for (final a in node.argumentList.arguments) {
      if (a is NamedExpression && a.name.label.name == 'shrinkWrap') return true;
    }
    return false;
  }

  static bool _hasParentList(InstanceCreationExpression node) {
    for (AstNode? p = node.parent; p != null; p = p.parent) {
      if (p is InstanceCreationExpression &&
          _scrollableParents.contains(p.typeName)) {
        return true;
      }
    }
    return false;
  }
}
