import '../arsync_lint_rule.dart';

/// A lint rule that identifies and discourages the use of consecutive
/// `SliverToBoxAdapter` widgets within a list.
///
/// Consecutive usage of `SliverToBoxAdapter` can lead to inefficient nesting
/// and performance issues in scrollable areas. It suggests using `SliverList.list`
/// or similar consolidated sliver widgets to optimize rendering performance.
///
/// ### Example
///
/// #### BAD:
/// ```dart
/// CustomScrollView(
///   slivers: <Widget>[
///     SliverToBoxAdapter(child: Text('Item 1')), // Consecutive usage
///     SliverToBoxAdapter(child: Text('Item 2')), // LINT
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
///         Text('Item 1'),
///         Text('Item 2'),
///       ],
///     ),
///   ],
/// );
/// ```
class AvoidConsecutiveSliverToBoxAdapter extends AnalysisRule {
  AvoidConsecutiveSliverToBoxAdapter()
    : super(name: code.name, description: code.problemMessage);

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
    // NOTE: We pass context.allUnits to the visitor because definingUnit.content
    // only returns the LIBRARY file content, not part file (.g.dart) content.
    // The visitor must use allUnits to get the correct file's content.

    final visitor = _Visitor(this, context.allUnits);
    registry.addListLiteral(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  _Visitor(this.rule, this.allUnits);

  final AnalysisRule rule;
  final List<dynamic> allUnits;

  @override
  void visitListLiteral(ListLiteral node) {
    // Skip generated files and nodes with ignore comments
    if (NodeContentHelper.shouldSkipNode(node, allUnits, rule.name)) return;

    final iterator = node.elements.iterator;
    if (!iterator.moveNext()) {
      // If there are no elements, there is nothing to check.
      return;
    }

    var current = iterator.current;
    while (iterator.moveNext()) {
      final next = iterator.current;
      if (_usesSliverToBoxAdapter(current) && _usesSliverToBoxAdapter(next)) {
        rule.reportAtNode(node);
        return;
      }
      current = next;
    }
  }

  bool _usesSliverToBoxAdapter(CollectionElement element) {
    if (element is! Expression) {
      return false;
    }
    return _isSliverToBoxAdapter(element) || _hasSliverToBoxAdapter(element);
  }

  bool _isSliverToBoxAdapter(Expression expression) {
    final typeName = expression.staticType?.getDisplayString();
    return typeName == 'SliverToBoxAdapter';
  }

  bool _hasSliverToBoxAdapter(Expression element) {
    if (element is! InstanceCreationExpression) {
      return false;
    }
    final arguments = element.argumentList.arguments;
    for (final argument in arguments) {
      if (argument is NamedExpression && argument.name.label.name == 'sliver') {
        final sliverExpression = argument.expression;
        final sliverTypeName = sliverExpression.staticType?.getDisplayString();
        if (sliverTypeName == 'SliverToBoxAdapter') {
          return true;
        }
      }
    }
    return false;
  }
}
