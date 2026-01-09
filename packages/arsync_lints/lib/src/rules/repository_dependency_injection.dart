import 'package:analyzer/source/line_info.dart';

import '../arsync_lint_rule.dart';

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
class RepositoryDependencyInjection extends MultiAnalysisRule {
  RepositoryDependencyInjection()
      : super(
          name: 'repository_dependency_injection',
          description:
              'Dependencies must be injected through constructor, not created directly.',
        );

  static const directInstantiationCode = LintCode(
    'repository_dependency_injection',
    'Dependencies must be injected through constructor, not created directly.',
    correctionMessage:
        'Remove the initializer and accept this dependency via constructor parameter.',
  );

  static const refNotAllowedCode = LintCode(
    'repository_dependency_injection',
    'Repositories cannot accept Ref as a parameter. Inject dependencies directly.',
    correctionMessage:
        'Remove Ref parameter and inject the actual dependencies (Dio, etc.) instead.',
  );

  @override
  List<DiagnosticCode> get diagnosticCodes =>
      [directInstantiationCode, refNotAllowedCode];

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    final path = context.definingUnit.file.path;
    if (!PathUtils.isInRepositories(path)) {
      return;
    }

    final content = context.definingUnit.content;
    final lineInfo = LineInfo.fromContent(content);

    final visitor = _Visitor(this, content, lineInfo);
    registry.addFieldDeclaration(this, visitor);
  }

  /// Check if the expression is creating an object instance
  static bool isObjectCreation(Expression expr) {
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

class _Visitor extends SimpleAstVisitor<void> {
  final MultiAnalysisRule rule;
  final String content;
  final LineInfo lineInfo;

  _Visitor(this.rule, this.content, this.lineInfo);

  @override
  void visitFieldDeclaration(FieldDeclaration node) {
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
          if (IgnoreUtils.shouldIgnoreAtOffset(
            offset: variable.name.offset,
            lintName: 'repository_dependency_injection',
            content: content,
            lineInfo: lineInfo,
          )) {
            continue;
          }
          rule.reportAtOffset(
            variable.name.offset,
            variable.name.length,
            diagnosticCode: RepositoryDependencyInjection.refNotAllowedCode,
          );
        }
        return;
      }
    }

    // Check each variable in the field declaration
    for (final variable in node.fields.variables) {
      final initializer = variable.initializer;
      if (initializer == null) continue;

      // Check if it's creating an object instance
      if (RepositoryDependencyInjection.isObjectCreation(initializer)) {
        if (IgnoreUtils.shouldIgnoreAtOffset(
          offset: initializer.offset,
          lintName: 'repository_dependency_injection',
          content: content,
          lineInfo: lineInfo,
        )) {
          continue;
        }
        rule.reportAtNode(
            initializer, diagnosticCode: RepositoryDependencyInjection.directInstantiationCode);
      }
    }
  }
}
