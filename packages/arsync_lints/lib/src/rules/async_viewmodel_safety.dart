import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../utils.dart';

/// Rule B4: async_viewmodel_safety
///
/// Async operations in ViewModels must handle errors explicitly.
class AsyncViewModelSafety extends DartLintRule {
  const AsyncViewModelSafety() : super(code: _code);

  static const _code = LintCode(
    name: 'async_viewmodel_safety',
    problemMessage:
        'Async operations in ViewModels must be wrapped in try/catch.',
    correctionMessage:
        'Add a try/catch block around the await call.',
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    // Only apply to files in lib/providers/
    if (!PathUtils.isInProviders(resolver.path)) {
      return;
    }

    context.registry.addClassDeclaration((node) {
      final extendsClause = node.extendsClause;
      if (extendsClause == null) return;

      final superclassName = extendsClause.superclass.name2.lexeme;

      // Only check Notifier and AsyncNotifier classes
      if (!superclassName.contains('Notifier') &&
          !superclassName.contains('AsyncNotifier')) {
        return;
      }

      // Check all methods in the class
      for (final member in node.members) {
        if (member is MethodDeclaration) {
          _checkMethod(member, reporter);
        }
      }
    });
  }

  void _checkMethod(MethodDeclaration method, ErrorReporter reporter) {
    final body = method.body;
    if (body is! BlockFunctionBody) return;

    // Check if method contains await expressions
    final awaitVisitor = _AwaitExpressionVisitor();
    body.accept(awaitVisitor);

    for (final awaitExpr in awaitVisitor.awaitExpressions) {
      // Check if this await is inside a try block
      if (!_isInsideTryBlock(awaitExpr)) {
        reporter.atNode(awaitExpr, _code);
      }
    }
  }

  bool _isInsideTryBlock(AstNode node) {
    AstNode? current = node.parent;
    while (current != null) {
      if (current is TryStatement) {
        return true;
      }
      // Stop at method boundary
      if (current is MethodDeclaration || current is FunctionDeclaration) {
        break;
      }
      current = current.parent;
    }
    return false;
  }
}

class _AwaitExpressionVisitor extends RecursiveAstVisitor<void> {
  final List<AwaitExpression> awaitExpressions = [];

  @override
  void visitAwaitExpression(AwaitExpression node) {
    awaitExpressions.add(node);
    super.visitAwaitExpression(node);
  }
}
