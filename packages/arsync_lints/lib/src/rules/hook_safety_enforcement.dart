import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../utils.dart';

/// Rule E1: hook_safety_enforcement
///
/// Hooks must be used correctly to prevent runtime crashes.
/// Ban: Instantiating TextEditingController, AnimationController, or
/// ScrollController directly in build without using a hook.
/// Ban: Using GlobalKey<FormState>() in HookWidget build methods (resets on
/// keyboard open, orientation change). Use GlobalObjectKey<FormState>(context).
class HookSafetyEnforcement extends DartLintRule {
  const HookSafetyEnforcement() : super(code: _code);

  static const _code = LintCode(
    name: 'hook_safety_enforcement',
    problemMessage:
        'Controllers must be created using hooks in build(). '
        'Use useTextEditingController, useAnimationController, etc.',
    correctionMessage:
        'Replace direct instantiation with the corresponding hook.',
  );

  static const _formKeyCode = LintCode(
    name: 'hook_safety_enforcement',
    problemMessage:
        'GlobalKey<FormState>() resets on keyboard open/orientation change in HookWidgets. '
        'Use GlobalObjectKey<FormState>(context) instead.',
    correctionMessage:
        'Replace GlobalKey<FormState>() with GlobalObjectKey<FormState>(context).',
  );

  static const _bannedControllers = [
    'TextEditingController',
    'AnimationController',
    'ScrollController',
    'PageController',
    'TabController',
    'FocusNode',
  ];

  /// HookWidget base classes where GlobalKey<FormState> should be avoided
  static const _hookWidgetClasses = {
    'HookWidget',
    'HookConsumerWidget',
  };

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    // Only apply to lib/ files
    if (!PathUtils.isInLib(resolver.path)) {
      return;
    }

    context.registry.addClassDeclaration((classNode) {
      // Check if this class extends a HookWidget
      final isHookWidget = _isHookWidgetClass(classNode);

      // Find the build method in this class
      for (final member in classNode.members) {
        if (member is MethodDeclaration && member.name.lexeme == 'build') {
          final body = member.body;

          // Check for banned controllers
          final controllerVisitor =
              _ControllerVisitor(reporter, _bannedControllers, _code);
          body.accept(controllerVisitor);

          // Check for GlobalKey<FormState>() in HookWidgets
          if (isHookWidget) {
            final formKeyVisitor = _FormKeyVisitor(reporter, _formKeyCode);
            body.accept(formKeyVisitor);
          }
        }
      }
    });
  }

  /// Check if class extends a HookWidget base class
  bool _isHookWidgetClass(ClassDeclaration node) {
    final extendsClause = node.extendsClause;
    if (extendsClause == null) return false;

    final superclassName = extendsClause.superclass.name2.lexeme;
    return _hookWidgetClasses.contains(superclassName);
  }
}

class _ControllerVisitor extends RecursiveAstVisitor<void> {
  final ErrorReporter reporter;
  final List<String> bannedControllers;
  final LintCode code;

  _ControllerVisitor(this.reporter, this.bannedControllers, this.code);

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    final typeName = node.constructorName.type.name2.lexeme;

    if (bannedControllers.contains(typeName)) {
      reporter.atNode(node, code);
    }

    super.visitInstanceCreationExpression(node);
  }
}

/// Visitor to detect GlobalKey<FormState>() usage in HookWidgets
class _FormKeyVisitor extends RecursiveAstVisitor<void> {
  final ErrorReporter reporter;
  final LintCode code;

  _FormKeyVisitor(this.reporter, this.code);

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    final typeName = node.constructorName.type.name2.lexeme;

    // Check for GlobalKey<FormState>()
    if (typeName == 'GlobalKey') {
      final typeArgs = node.constructorName.type.typeArguments;
      if (typeArgs != null && typeArgs.arguments.isNotEmpty) {
        final typeArg = typeArgs.arguments.first;
        if (typeArg is NamedType && typeArg.name2.lexeme == 'FormState') {
          reporter.atNode(node, code);
        }
      }
    }

    super.visitInstanceCreationExpression(node);
  }
}
