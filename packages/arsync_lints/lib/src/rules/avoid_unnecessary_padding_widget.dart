import '../arsync_lint_rule.dart';

/// A lint rule that discourages unnecessary use of the `Padding` widget
/// when `Container` properties can be used instead.
///
/// This rule detects two patterns:
/// 1. `Padding` wrapping a `Container` - use Container's `margin` instead
/// 2. `Container` wrapping a `Padding` - use Container's `padding` instead
///
/// ### Example
///
/// #### BAD: Padding wrapping Container
/// ```dart
/// Padding(
///   padding: EdgeInsets.all(8),
///   child: Container(
///     color: Colors.red,
///   ),
/// )
/// ```
///
/// #### GOOD: Use Container's margin
/// ```dart
/// Container(
///   margin: EdgeInsets.all(8),
///   color: Colors.red,
/// )
/// ```
///
/// #### BAD: Container wrapping Padding
/// ```dart
/// Container(
///   color: Colors.red,
///   child: Padding(
///     padding: EdgeInsets.all(8),
///     child: Text('Hello'),
///   ),
/// )
/// ```
///
/// #### GOOD: Use Container's padding
/// ```dart
/// Container(
///   color: Colors.red,
///   padding: EdgeInsets.all(8),
///   child: Text('Hello'),
/// )
/// ```
class AvoidUnnecessaryPaddingWidget extends MultiAnalysisRule {
  AvoidUnnecessaryPaddingWidget()
    : super(
        name: 'avoid_unnecessary_padding_widget',
        description: paddingWrapsContainerCode.problemMessage,
      );

  static const paddingWrapsContainerCode = LintCode(
    'avoid_unnecessary_padding_widget',
    'Avoid wrapping Container with Padding widget.',
    correctionMessage:
        'Use the margin property of Container instead of wrapping it with Padding.',
  );

  static const containerWrapsPaddingCode = LintCode(
    'avoid_unnecessary_padding_widget',
    'Avoid using Padding as child of Container.',
    correctionMessage:
        'Use the padding property of Container instead of using Padding as child.',
  );

  @override
  List<DiagnosticCode> get diagnosticCodes => [
    paddingWrapsContainerCode,
    containerWrapsPaddingCode,
  ];

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    // NOTE: We pass context.allUnits to the visitor because definingUnit.content
    // only returns the LIBRARY file content, not part file (.g.dart) content.
    // The visitor must use allUnits to get the correct file's content.

    final visitor = _Visitor(this, context.allUnits);
    registry.addInstanceCreationExpression(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  _Visitor(this.rule, this.allUnits);

  final AvoidUnnecessaryPaddingWidget rule;
  final List<dynamic> allUnits;

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    // Skip generated files and nodes with ignore comments
    if (NodeContentHelper.shouldSkipNode(node, allUnits, rule.name)) return;

    final constructorName = node.constructorName.type.name.lexeme;

    if (constructorName == 'Padding') {
      _checkPaddingWrapsContainer(node);
    } else if (constructorName == 'Container') {
      _checkContainerWrapsPadding(node);
    }
  }

  /// Check if Padding wraps a Container (should use Container's margin instead)
  void _checkPaddingWrapsContainer(InstanceCreationExpression paddingNode) {
    final childArg = _getChildArgument(paddingNode);
    if (childArg == null) return;

    final childExpression = childArg.expression;
    if (childExpression is InstanceCreationExpression) {
      final childConstructorName =
          childExpression.constructorName.type.name.lexeme;

      if (childConstructorName == 'Container') {
        // Check if Container already has a margin property
        final containerHasMargin = _hasNamedArgument(childExpression, 'margin');

        // Only report if Container doesn't already have margin
        if (!containerHasMargin) {
          rule.reportAtOffset(
            paddingNode.offset,
            paddingNode.length,
            diagnosticCode:
                AvoidUnnecessaryPaddingWidget.paddingWrapsContainerCode,
          );
        }
      }
    }
  }

  /// Check if Container wraps a Padding (should use Container's padding instead)
  void _checkContainerWrapsPadding(InstanceCreationExpression containerNode) {
    // Check if Container already has a padding property
    final containerHasPadding = _hasNamedArgument(containerNode, 'padding');
    if (containerHasPadding) return;

    final childArg = _getChildArgument(containerNode);
    if (childArg == null) return;

    final childExpression = childArg.expression;
    if (childExpression is InstanceCreationExpression) {
      final childConstructorName =
          childExpression.constructorName.type.name.lexeme;

      if (childConstructorName == 'Padding') {
        rule.reportAtOffset(
          containerNode.offset,
          containerNode.length,
          diagnosticCode:
              AvoidUnnecessaryPaddingWidget.containerWrapsPaddingCode,
        );
      }
    }
  }

  NamedExpression? _getChildArgument(InstanceCreationExpression node) {
    return node.argumentList.arguments
        .whereType<NamedExpression>()
        .where((arg) => arg.name.label.name == 'child')
        .firstOrNull;
  }

  bool _hasNamedArgument(InstanceCreationExpression node, String argName) {
    return node.argumentList.arguments.whereType<NamedExpression>().any(
      (arg) => arg.name.label.name == argName,
    );
  }
}
