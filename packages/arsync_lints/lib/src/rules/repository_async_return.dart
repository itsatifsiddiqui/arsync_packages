import '../arsync_lint_rule.dart';

/// Rule C2: in `lib/repositories/`, public methods must return `Future<T>` or
/// `Stream<T>` — repositories can't block the main thread.
class RepositoryAsyncReturn extends AnalysisRule {
  RepositoryAsyncReturn() : super(name: code.lowerCaseName, description: code.problemMessage);

  static const LintCode code = LintCode(
    'repository_async_return',
    'Repository public methods must return Future<T> or Stream<T>.',
    correctionMessage: 'Change the return type to Future<T> or Stream<T>.',
  );

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    if (!PathUtils.isInRepositories(context.definingUnit.file.path)) return;
    registry.addClassDeclaration(this, _Visitor(this));
  }
}

class _Visitor extends ArsyncRuleVisitor<AnalysisRule> {
  _Visitor(super.rule);

  @override
  void visitClassDeclaration(ClassDeclaration node) {

    for (final m in node.classMembers.whereType<MethodDeclaration>()) {
      if (m.name.lexeme.startsWith('_') || m.isGetter || m.isSetter) continue;
      final returnType = m.returnType;
      if (returnType == null) continue;
      final src = returnType.toSource();
      final valid = src == 'Future' ||
          src == 'Stream' ||
          src.startsWith('Future<') ||
          src.startsWith('Stream<');
      if (!valid) rule.reportAtNode(returnType);
    }
  }
}
