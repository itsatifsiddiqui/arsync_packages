import '../arsync_lint_rule.dart';

/// Rule E1: controllers must be created via hooks inside `build()`
/// (`useTextEditingController`, `useAnimationController`, …) — never with
/// direct constructors. Also bans `GlobalKey<FormState>()` inside HookWidgets
/// because it resets on rebuild.
class HookSafetyEnforcement extends MultiAnalysisRule {
  HookSafetyEnforcement()
    : super(
        name: 'hook_safety_enforcement',
        description:
            'Controllers must be created using hooks in build() methods.',
      );

  static const controllerCode = LintCode(
    'hook_safety_enforcement',
    'Controllers must be created using hooks in build(). '
        'Use useTextEditingController, useAnimationController, etc.',
    correctionMessage:
        'Replace direct instantiation with the corresponding hook.',
  );

  static const formKeyCode = LintCode(
    'hook_safety_enforcement',
    'GlobalKey<FormState>() resets on keyboard open/orientation change in HookWidgets. '
        'Use GlobalObjectKey<FormState>(context) instead.',
    correctionMessage:
        'Replace GlobalKey<FormState>() with GlobalObjectKey<FormState>(context).',
  );

  @override
  List<DiagnosticCode> get diagnosticCodes => [controllerCode, formKeyCode];

  static const bannedControllers = {
    'TextEditingController',
    'AnimationController',
    'ScrollController',
    'PageController',
    'TabController',
    'FocusNode',
  };

  static const hookWidgetClasses = {'HookWidget', 'HookConsumerWidget'};

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    if (!context.isInLibDir) return;
    registry.addInstanceCreationExpression(
      this,
      _Visitor(this),
    );
  }
}

class _Visitor extends ArsyncRuleVisitor<MultiAnalysisRule> {
  _Visitor(super.rule);

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {

    final method = node.thisOrAncestorOfType<MethodDeclaration>();
    if (method == null || method.name.lexeme != 'build') return;

    final typeName = node.constructorName.type.name.lexeme;
    if (HookSafetyEnforcement.bannedControllers.contains(typeName)) {
      rule.reportAtNode(
        node,
        diagnosticCode: HookSafetyEnforcement.controllerCode,
      );
      return;
    }

    if (typeName != 'GlobalKey' || !_isInHookWidget(node)) return;
    final typeArg = node.constructorName.type.typeArguments?.arguments.firstOrNull;
    if (typeArg is NamedType && typeArg.name.lexeme == 'FormState') {
      rule.reportAtNode(
        node,
        diagnosticCode: HookSafetyEnforcement.formKeyCode,
      );
    }
  }

  static bool _isInHookWidget(AstNode node) =>
      HookSafetyEnforcement.hookWidgetClasses.contains(
        node
            .thisOrAncestorOfType<ClassDeclaration>()
            ?.extendsClause
            ?.superclass
            .name
            .lexeme,
      );
}
