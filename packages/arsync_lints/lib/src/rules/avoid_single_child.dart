import '../arsync_lint_rule.dart';

/// A lint rule that warns against using layout widgets intended for multiple
/// children with only one child.
///
/// This includes widgets like `Column`, `Row`, `Stack`, `Flex`, `Wrap`,
/// `ListView`, `SliverList`, `SliverMainAxisGroup`, and `SliverCrossAxisGroup`.
///
/// Using these widgets with a single child can lead to unnecessary overhead
/// and less efficient layouts.
///
/// ### Example
///
/// #### BAD:
/// ```dart
/// Column(
///   children: <Widget>[YourWidget()], // LINT
/// );
/// ```
///
/// #### GOOD:
/// ```dart
/// Center(child: YourWidget());
/// // or
/// Column(
///   children: <Widget>[YourWidget1(), YourWidget2()],
/// );
/// ```
class AvoidSingleChild extends AnalysisRule {
  AvoidSingleChild() : super(name: code.name, description: code.problemMessage);

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

  static const _multiChildWidgets = [
    'Column',
    'Row',
    'Flex',
    'Wrap',
    'Stack',
    'ListView',
    'SliverList',
    'SliverMainAxisGroup',
    'SliverCrossAxisGroup',
  ];

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    // Skip generated files and nodes with ignore comments
    if (NodeContentHelper.shouldSkipNode(node, allUnits, rule.name)) return;

    final className = node.staticType?.getDisplayString();
    if (!_multiChildWidgets.contains(className)) {
      return;
    }

    final childrenArg = _findChildrenArgument(node);
    if (childrenArg == null) {
      return;
    }

    final ListLiteral childrenList;
    if (childrenArg is NamedExpression &&
        childrenArg.expression is ListLiteral) {
      childrenList = childrenArg.expression as ListLiteral;
    } else {
      return;
    }

    if (childrenList.elements.length != 1) {
      return;
    }

    // Check for edge cases where single child is acceptable
    for (final element in childrenList.elements) {
      if (element is IfElement) {
        if (_hasMultipleChildren(element.thenElement)) {
          return;
        }

        final elseElement = element.elseElement;
        if (elseElement != null && _hasMultipleChildren(elseElement)) {
          return;
        }
      }
    }

    final element = childrenList.elements.first;
    // ForElement generates multiple children at runtime
    if (element is ForElement) {
      return;
    }

    rule.reportAtNode(node);
  }

  Expression? _findChildrenArgument(InstanceCreationExpression node) {
    for (final arg in node.argumentList.arguments) {
      if (arg is NamedExpression &&
          (arg.name.label.name == 'children' ||
              arg.name.label.name == 'slivers')) {
        return arg;
      }
    }
    return null;
  }

  bool _hasMultipleChildren(CollectionElement element) {
    if (element is SpreadElement && element.expression is ListLiteral) {
      final spreadElement = element.expression as ListLiteral;
      return spreadElement.elements.length > 1;
    }
    return false;
  }
}
