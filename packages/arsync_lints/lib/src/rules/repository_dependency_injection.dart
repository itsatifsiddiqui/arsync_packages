import '../arsync_lint_rule.dart';

/// Rule: repository_dependency_injection
///
/// Repositories cannot create object instances directly in field declarations.
/// All dependencies must be injected through the constructor.
/// Repositories cannot accept Ref as a constructor parameter.
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
    if (!PathUtils.isInRepositories(path)) return;

    final visitor = _Visitor(this);
    registry.addFieldDeclaration(this, visitor);
  }

  static bool isObjectCreation(Expression expr) {
    if (expr is InstanceCreationExpression) return true;

    if (expr is MethodInvocation) {
      final target = expr.target;
      if (target is SimpleIdentifier) {
        final methodName = expr.methodName.name;
        if (methodName == 'create' ||
            methodName == 'instance' ||
            methodName == 'getInstance') {
          return true;
        }
      }
    }

    return false;
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final MultiAnalysisRule rule;

  _Visitor(this.rule);

  @override
  void visitFieldDeclaration(FieldDeclaration node) {
    final parent = node.parent;
    if (parent is! ClassDeclaration) return;

    final className = parent.name.lexeme;
    if (!className.endsWith('Repository')) return;

    final typeAnnotation = node.fields.type;
    if (typeAnnotation != null) {
      final typeName = typeAnnotation.toSource();
      if (typeName == 'Ref' || typeName.startsWith('Ref<')) {
        for (final variable in node.fields.variables) {
          rule.reportAtOffset(
            variable.name.offset,
            variable.name.length,
            diagnosticCode: RepositoryDependencyInjection.refNotAllowedCode,
          );
        }
        return;
      }
    }

    for (final variable in node.fields.variables) {
      final initializer = variable.initializer;
      if (initializer == null) continue;

      if (RepositoryDependencyInjection.isObjectCreation(initializer)) {
        rule.reportAtNode(
            initializer, diagnosticCode: RepositoryDependencyInjection.directInstantiationCode);
      }
    }
  }
}
