import '../arsync_lint_rule.dart';

const _hookWidgetName = 'HookWidget';
const _hookNameRegex = r'^_?use[A-Z].*';
const _statelessWidgetName = 'StatelessWidget';

/// A lint rule that detects `HookWidget` usage without any hooks.
///
/// When a widget extends `HookWidget` but doesn't use any hooks,
/// it should be replaced with `StatelessWidget` for clarity and performance.
///
/// ### Example
///
/// #### BAD:
/// ```dart
/// class NoHooksWidget extends HookWidget {
///   const NoHooksWidget({super.key});
///
///   @override
///   Widget build(BuildContext context) => const Text('Hello World!');
/// }
/// ```
///
/// #### GOOD:
/// ```dart
/// class NoHooksWidget extends StatelessWidget {
///   const NoHooksWidget({super.key});
///
///   @override
///   Widget build(BuildContext context) => const Text('Hello World!');
/// }
/// ```
///
/// #### GOOD (using hooks):
/// ```dart
/// class MyHookWidget extends HookWidget {
///   const MyHookWidget({super.key});
///
///   @override
///   Widget build(BuildContext context) {
///     final controller = useTextEditingController();
///     return TextField(controller: controller);
///   }
/// }
/// ```
class UnnecessaryHookWidget extends AnalysisRule {
  UnnecessaryHookWidget()
    : super(name: code.name, description: code.problemMessage);

  static const code = LintCode(
    'unnecessary_hook_widget',
    'Consider using StatelessWidget instead of HookWidget when no hooks are used.',
    correctionMessage: 'Replace with $_statelessWidgetName.',
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
    registry.addClassDeclaration(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  _Visitor(this.rule, this.ignoreChecker);

  final AnalysisRule rule;
  final IgnoreChecker ignoreChecker;

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    if (ignoreChecker.shouldIgnore(node)) return;

    final superclass = node.extendsClause?.superclass;
    if (superclass == null) return;

    // Check if the superclass is HookWidget
    if (superclass.name.lexeme != _hookWidgetName) return;

    // Check if any hooks are used within the class
    var hasHooks = false;
    node.visitChildren(
      _HookDetectorVisitor(() {
        hasHooks = true;
      }),
    );

    if (!hasHooks) {
      rule.reportAtNode(superclass);
    }
  }
}

class _HookDetectorVisitor extends RecursiveAstVisitor<void> {
  const _HookDetectorVisitor(this.onHookFound);

  final void Function() onHookFound;

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (RegExp(_hookNameRegex).hasMatch(node.methodName.name)) {
      onHookFound();
    }
    // for hooks like `useTextEditingController.call()`
    final target = node.realTarget;
    if (target != null && target is SimpleIdentifier) {
      if (RegExp(_hookNameRegex).hasMatch(target.name)) {
        onHookFound();
      }
    }
    super.visitMethodInvocation(node);
  }

  // for hooks like `useTextEditingController()`
  @override
  void visitFunctionExpressionInvocation(FunctionExpressionInvocation node) {
    final function = node.function;
    if (function is SimpleIdentifier) {
      if (RegExp(_hookNameRegex).hasMatch(function.name)) {
        onHookFound();
      }
    }
    super.visitFunctionExpressionInvocation(node);
  }
}
