import '../arsync_lint_rule.dart';

/// A lint rule that discourages using `shrinkWrap` with `ListView`.
///
/// This property causes performance issues by requiring the list to fully layout
/// its content upfront. Instead of `shrinkWrap`, consider using slivers for better
/// performance with large lists.
///
/// ### Example
///
/// #### BAD:
/// ```dart
/// ListView(
///   shrinkWrap: true, // LINT
///   children: <Widget>[
///     Text('Hello'),
///     Text('World'),
///   ],
/// );
/// ```
///
/// #### GOOD:
/// ```dart
/// CustomScrollView(
///   slivers: <Widget>[
///     SliverList.list(
///       children: [
///         Text('Hello'),
///         Text('World'),
///       ],
///     ),
///   ],
/// );
/// ```
class AvoidShrinkWrapInListView extends AnalysisRule {
  AvoidShrinkWrapInListView()
    : super(name: code.name, description: code.problemMessage);

  static const code = LintCode(
    'avoid_shrink_wrap_in_list_view',
    'Avoid using ListView with shrinkWrap, '
        'since it might degrade the performance.',
    correctionMessage:
        'You can avoid shrink wrapping with the following 3 steps if your scroll view is nested:'
        ''
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
    // NOTE: We pass context.allUnits to the visitor because definingUnit.content
    // only returns the LIBRARY file content, not part file (.g.dart) content.
    final visitor = _Visitor(this, context.allUnits);
    registry.addInstanceCreationExpression(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  _Visitor(this.rule, this.allUnits);

  final AnalysisRule rule;
  final List<dynamic> allUnits;

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    // Skip generated files and nodes with ignore comments
    if (NodeContentHelper.shouldSkipNode(node, allUnits, rule.name)) return;

    final typeName = node.staticType?.getDisplayString();
    if (TypeUtils.isListViewWidget(typeName) &&
        _hasShrinkWrap(node) &&
        _hasParentList(node)) {
      rule.reportAtNode(node);
    }
  }

  bool _hasShrinkWrap(InstanceCreationExpression node) {
    for (final arg in node.argumentList.arguments) {
      if (arg is NamedExpression && arg.name.label.name == 'shrinkWrap') {
        return true;
      }
    }
    return false;
  }

  bool _hasParentList(InstanceCreationExpression node) {
    AstNode? parent = node.parent;
    while (parent != null) {
      if (parent != node && parent is InstanceCreationExpression) {
        final parentTypeName = parent.staticType?.getDisplayString();
        if (TypeUtils.isListViewWidget(parentTypeName) ||
            TypeUtils.isColumnWidget(parentTypeName) ||
            TypeUtils.isRowWidget(parentTypeName)) {
          return true;
        }
      }
      parent = parent.parent;
    }
    return false;
  }
}
