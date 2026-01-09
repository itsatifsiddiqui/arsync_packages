import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../utils.dart';

/// Rule: repository_dependency_injection
///
/// Repositories cannot create object instances directly in field declarations.
/// All dependencies must be injected through the constructor.
/// Repositories cannot accept Ref as a constructor parameter.
///
/// Good:
/// ```dart
/// class AuthRepository {
///   final Dio _dio;
///   AuthRepository(this._dio);
/// }
/// ```
///
/// Bad:
/// ```dart
/// class AuthRepository {
///   final Dio _dio = Dio(); // Direct instantiation!
///   final Ref ref; // Ref not allowed!
///   AuthRepository(this._dio, this.ref);
/// }
/// ```
class RepositoryDependencyInjection extends DartLintRule {
  const RepositoryDependencyInjection() : super(code: _code);

  static const _code = LintCode(
    name: 'repository_dependency_injection',
    problemMessage:
        'Dependencies must be injected through constructor, not created directly.',
    correctionMessage:
        'Remove the initializer and accept this dependency via constructor parameter.',
  );

  static const _refNotAllowedCode = LintCode(
    name: 'repository_dependency_injection',
    problemMessage:
        'Repositories cannot accept Ref as a parameter. Inject dependencies directly.',
    correctionMessage:
        'Remove Ref parameter and inject the actual dependencies (Dio, etc.) instead.',
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    // Only apply to files in repositories directory
    if (!PathUtils.isInRepositories(resolver.path)) {
      return;
    }

    context.registry.addFieldDeclaration((node) {
      // Get the parent class
      final parent = node.parent;
      if (parent is! ClassDeclaration) return;

      final className = parent.name.lexeme;

      // Only check Repository classes
      if (!className.endsWith('Repository')) return;

      // Check if field type is Ref (not allowed in repositories)
      final typeAnnotation = node.fields.type;
      if (typeAnnotation != null) {
        final typeName = typeAnnotation.toSource();
        if (typeName == 'Ref' || typeName.startsWith('Ref<')) {
          for (final variable in node.fields.variables) {
            reporter.atToken(variable.name, _refNotAllowedCode);
          }
          return;
        }
      }

      // Check each variable in the field declaration
      for (final variable in node.fields.variables) {
        final initializer = variable.initializer;
        if (initializer == null) continue;

        // Check if it's creating an object instance
        if (_isObjectCreation(initializer)) {
          reporter.atNode(initializer, _code);
        }
      }
    });
  }

  /// Check if the expression is creating an object instance
  bool _isObjectCreation(Expression expr) {
    // Direct constructor call: Dio(), HttpClient(), etc.
    if (expr is InstanceCreationExpression) {
      return true;
    }

    // Method invocation that creates instance: SomeClass.create(), etc.
    if (expr is MethodInvocation) {
      final target = expr.target;
      // Factory methods like Dio.create() or similar
      if (target is SimpleIdentifier) {
        final methodName = expr.methodName.name;
        // Common factory method patterns
        if (methodName == 'create' ||
            methodName == 'instance' ||
            methodName == 'getInstance') {
          return true;
        }
      }
    }

    // Prefix expression with constructor: dio.Dio()
    if (expr is PrefixedIdentifier) {
      return false; // This is typically accessing a property, not creating
    }

    return false;
  }
}
