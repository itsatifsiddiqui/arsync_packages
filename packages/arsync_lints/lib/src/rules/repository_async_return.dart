import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../utils.dart';

/// Rule C2: repository_async_return
///
/// Repositories must not block the main thread.
/// Public methods must return `Future<T>` or `Stream<T>`.
class RepositoryAsyncReturn extends DartLintRule {
  const RepositoryAsyncReturn() : super(code: _code);

  static const _code = LintCode(
    name: 'repository_async_return',
    problemMessage:
        'Repository public methods must return Future<T> or Stream<T>.',
    correctionMessage:
        'Change the return type to Future<T> or Stream<T>.',
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    // Only apply to files in lib/repositories/
    if (!PathUtils.isInRepositories(resolver.path)) {
      return;
    }

    context.registry.addClassDeclaration((node) {
      for (final member in node.members) {
        if (member is MethodDeclaration) {
          _checkMethod(member, reporter);
        }
      }
    });
  }

  void _checkMethod(MethodDeclaration method, ErrorReporter reporter) {
    final methodName = method.name.lexeme;

    // Skip private methods (starting with _)
    if (methodName.startsWith('_')) return;

    // Skip getters and setters
    if (method.isGetter || method.isSetter) return;

    // Skip constructors (they don't have returnType in the same way)
    final returnType = method.returnType;
    if (returnType == null) return;

    final returnTypeName = returnType.toSource();

    // Check if return type is Future<T> or Stream<T>
    final isValidReturn = returnTypeName.startsWith('Future<') ||
        returnTypeName.startsWith('Stream<') ||
        returnTypeName == 'Future' ||
        returnTypeName == 'Stream';

    if (!isValidReturn) {
      reporter.atNode(returnType, _code);
    }
  }
}
