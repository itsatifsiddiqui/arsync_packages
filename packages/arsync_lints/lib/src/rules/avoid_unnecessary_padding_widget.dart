import '../arsync_lint_rule.dart';

/// Lint rule discouraging unnecessary `Padding` widgets when `Container`
/// properties suffice:
/// 1. `Padding` wrapping a `Container` — use `Container.margin` instead.
/// 2. `Container` wrapping a `Padding` — use `Container.padding` instead.
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
    registry.addInstanceCreationExpression(
      this,
      _Visitor(this),
    );
  }
}

class _Visitor extends ArsyncRuleVisitor<AvoidUnnecessaryPaddingWidget> {
  _Visitor(super.rule);

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {

    final type = node.constructorName.type.name.lexeme;
    final child = _namedArg(node, 'child')?.expression;
    if (child is! InstanceCreationExpression) return;
    final childType = child.constructorName.type.name.lexeme;

    // Padding(child: Container(...)) — flag the Padding unless Container already has margin.
    if (type == 'Padding' &&
        childType == 'Container' &&
        !_hasNamedArg(child, 'margin')) {
      rule.reportAtOffset(
        node.offset,
        node.length,
        diagnosticCode:
            AvoidUnnecessaryPaddingWidget.paddingWrapsContainerCode,
      );
      return;
    }

    // Container(child: Padding(...)) — flag the Container unless it already has padding.
    if (type == 'Container' &&
        childType == 'Padding' &&
        !_hasNamedArg(node, 'padding')) {
      rule.reportAtOffset(
        node.offset,
        node.length,
        diagnosticCode:
            AvoidUnnecessaryPaddingWidget.containerWrapsPaddingCode,
      );
    }
  }

  static NamedExpression? _namedArg(
    InstanceCreationExpression node,
    String name,
  ) =>
      node.argumentList.arguments
          .whereType<NamedExpression>()
          .where((a) => a.name.label.name == name)
          .firstOrNull;

  static bool _hasNamedArg(InstanceCreationExpression node, String name) =>
      _namedArg(node, name) != null;
}
