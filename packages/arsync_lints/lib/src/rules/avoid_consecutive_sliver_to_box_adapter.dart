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
    final content = context.definingUnit.content;
    final ignoreChecker = IgnoreChecker.forRule(content, name);
    if (ignoreChecker.ignoreForFile) return;

    final visitor = _Visitor(this, ignoreChecker);
    registry.addListLiteral(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  _Visitor(this.rule, this.ignoreChecker);

  final AnalysisRule rule;
  final IgnoreChecker ignoreChecker;

  @override
  void visitListLiteral(ListLiteral node) {
    if (ignoreChecker.shouldIgnore(node)) return;

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
