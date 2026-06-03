import '../arsync_lint_rule.dart';

/// Rule: in `lib/repositories/`, fields must not directly instantiate
/// dependencies and `Ref` must not be a constructor parameter — repositories
/// receive dependencies via constructor injection.
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
  List<DiagnosticCode> get diagnosticCodes => [
    directInstantiationCode,
    refNotAllowedCode,
  ];

  static const _factoryMethods = {'create', 'instance', 'getInstance'};

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    if (!PathUtils.isInRepositories(context.definingUnit.file.path)) return;
    registry.addFieldDeclaration(this, _Visitor(this));
  }

  static bool isObjectCreation(Expression expr) {
    if (expr is InstanceCreationExpression) return true;
    if (expr is MethodInvocation && expr.target is SimpleIdentifier) {
      return _factoryMethods.contains(expr.methodName.name);
    }
    return false;
  }
}

class _Visitor extends ArsyncRuleVisitor<MultiAnalysisRule> {
  _Visitor(super.rule);

  @override
  void visitFieldDeclaration(FieldDeclaration node) {

    final parent = node.parent;
    if (parent is! ClassDeclaration ||
        !parent.className.lexeme.endsWith('Repository')) {
      return;
    }

    final typeName = node.fields.type?.toSource();
    if (typeName != null &&
        (typeName == 'Ref' || typeName.startsWith('Ref<'))) {
      for (final v in node.fields.variables) {
        rule.reportAtOffset(
          v.name.offset,
          v.name.length,
          diagnosticCode: RepositoryDependencyInjection.refNotAllowedCode,
        );
      }
      return;
    }

    for (final v in node.fields.variables) {
      final init = v.initializer;
      if (init != null && RepositoryDependencyInjection.isObjectCreation(init)) {
        rule.reportAtNode(
          init,
          diagnosticCode:
              RepositoryDependencyInjection.directInstantiationCode,
        );
      }
    }
  }
}
