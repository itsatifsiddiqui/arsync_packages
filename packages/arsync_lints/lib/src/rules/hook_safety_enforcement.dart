import 'package:analyzer/source/line_info.dart';

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

  static const hookWidgetClasses = {
    'HookWidget',
    'HookConsumerWidget',
  };

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    if (!context.isInLibDir) {
      return;
    }

    final content = context.definingUnit.content;
    final lineInfo = LineInfo.fromContent(content);

    var visitor = _Visitor(this, content, lineInfo);
    registry.addClassDeclaration(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final MultiAnalysisRule rule;
  final String content;
  final LineInfo lineInfo;

  _Visitor(this.rule, this.content, this.lineInfo);

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    final isHookWidget = _isHookWidgetClass(node);

    for (final member in node.members) {
      if (member is MethodDeclaration && member.name.lexeme == 'build') {
        final body = member.body;

        // Check for banned controllers
        final controllerVisitor = _ControllerVisitor(rule, content, lineInfo);
        body.accept(controllerVisitor);

        // Check for GlobalKey<FormState>() in HookWidgets
        if (isHookWidget) {
          final formKeyVisitor = _FormKeyVisitor(rule, content, lineInfo);
          body.accept(formKeyVisitor);
        }
      }
    }
  }

  bool _isHookWidgetClass(ClassDeclaration node) {
    final extendsClause = node.extendsClause;
    if (extendsClause == null) return false;

    final superclassName = extendsClause.superclass.name.lexeme;
    return HookSafetyEnforcement.hookWidgetClasses.contains(superclassName);
  }
}

class _ControllerVisitor extends RecursiveAstVisitor<void> {
  final MultiAnalysisRule rule;
  final String content;
  final LineInfo lineInfo;

  _ControllerVisitor(this.rule, this.content, this.lineInfo);

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    final typeName = node.constructorName.type.name.lexeme;

    if (HookSafetyEnforcement.bannedControllers.contains(typeName)) {
      if (!IgnoreUtils.shouldIgnoreAtOffset(
        offset: node.offset,
        lintName: 'hook_safety_enforcement',
        content: content,
        lineInfo: lineInfo,
      )) {
        rule.reportAtNode(node, diagnosticCode: HookSafetyEnforcement.controllerCode);
      }
    }

    super.visitInstanceCreationExpression(node);
  }
}

class _FormKeyVisitor extends RecursiveAstVisitor<void> {
  final MultiAnalysisRule rule;
  final String content;
  final LineInfo lineInfo;

  _FormKeyVisitor(this.rule, this.content, this.lineInfo);

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    final typeName = node.constructorName.type.name.lexeme;

    if (typeName == 'GlobalKey') {
      final typeArgs = node.constructorName.type.typeArguments;
      if (typeArgs != null && typeArgs.arguments.isNotEmpty) {
        final typeArg = typeArgs.arguments.first;
        if (typeArg is NamedType && typeArg.name.lexeme == 'FormState') {
          if (!IgnoreUtils.shouldIgnoreAtOffset(
            offset: node.offset,
            lintName: 'hook_safety_enforcement',
            content: content,
            lineInfo: lineInfo,
          )) {
            rule.reportAtNode(node, diagnosticCode: HookSafetyEnforcement.formKeyCode);
          }
        }
      }
    }

    super.visitInstanceCreationExpression(node);
  }
}
