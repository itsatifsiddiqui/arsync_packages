import '../arsync_lint_rule.dart';

/// Rule E1: hook_safety_enforcement
///
/// Hooks must be used correctly to prevent runtime crashes.
/// Ban: Instantiating TextEditingController, AnimationController, or
/// ScrollController directly in build without using a hook.
/// Ban: Using `GlobalKey<FormState>()` in HookWidget build methods.
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

  static const bannedControllers = [
    'TextEditingController',
    'AnimationController',
    'ScrollController',
    'PageController',
    'TabController',
    'FocusNode',
  ];

  static const hookWidgetClasses = {'HookWidget', 'HookConsumerWidget'};

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    if (!context.isInLibDir) return;

    // NOTE: We pass context.allUnits to the visitor because definingUnit.content
    // only returns the LIBRARY file content, not part file (.g.dart) content.
    // The visitor must use allUnits to get the correct file's content.

    var visitor = _Visitor(this, context.allUnits);
    registry.addClassDeclaration(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final MultiAnalysisRule rule;
  final List<dynamic> allUnits;

  _Visitor(this.rule, this.allUnits);

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    // Skip generated files and nodes with ignore comments
    if (NodeContentHelper.shouldSkipNode(node, allUnits, rule.name)) return;
    final isHookWidget = _isHookWidgetClass(node);

    for (final member in node.members) {
      if (member is MethodDeclaration && member.name.lexeme == 'build') {
        final body = member.body;

        final controllerVisitor = _ControllerVisitor(rule, allUnits);
        body.accept(controllerVisitor);

        if (isHookWidget) {
          final formKeyVisitor = _FormKeyVisitor(rule, allUnits);
          body.accept(formKeyVisitor);
        }
      }
    }
  }

  bool _isHookWidgetClass(ClassDeclaration node) {
    final extendsClause = node.extendsClause;
    if (extendsClause == null) return false;
    return HookSafetyEnforcement.hookWidgetClasses.contains(
      extendsClause.superclass.name.lexeme,
    );
  }
}

class _ControllerVisitor extends RecursiveAstVisitor<void> {
  final MultiAnalysisRule rule;
  final List<dynamic> allUnits;

  _ControllerVisitor(this.rule, this.allUnits);

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    if (NodeContentHelper.shouldSkipNode(node, allUnits, rule.name)) {
      super.visitInstanceCreationExpression(node);
      return;
    }
    final typeName = node.constructorName.type.name.lexeme;

    if (HookSafetyEnforcement.bannedControllers.contains(typeName)) {
      rule.reportAtNode(
        node,
        diagnosticCode: HookSafetyEnforcement.controllerCode,
      );
    }

    super.visitInstanceCreationExpression(node);
  }
}

class _FormKeyVisitor extends RecursiveAstVisitor<void> {
  final MultiAnalysisRule rule;
  final List<dynamic> allUnits;

  _FormKeyVisitor(this.rule, this.allUnits);

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    if (NodeContentHelper.shouldSkipNode(node, allUnits, rule.name)) {
      super.visitInstanceCreationExpression(node);
      return;
    }
    final typeName = node.constructorName.type.name.lexeme;

    if (typeName == 'GlobalKey') {
      final typeArgs = node.constructorName.type.typeArguments;
      if (typeArgs != null && typeArgs.arguments.isNotEmpty) {
        final typeArg = typeArgs.arguments.first;
        if (typeArg is NamedType && typeArg.name.lexeme == 'FormState') {
          rule.reportAtNode(
            node,
            diagnosticCode: HookSafetyEnforcement.formKeyCode,
          );
        }
      }
    }

    super.visitInstanceCreationExpression(node);
  }
}
