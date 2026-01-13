import '../arsync_lint_rule.dart';

/// Rule C2: repository_async_return
///
/// Repositories must not block the main thread.
/// Public methods must return `Future<T>` or `Stream<T>`.
class RepositoryAsyncReturn extends AnalysisRule {
  RepositoryAsyncReturn()
    : super(
        name: 'repository_async_return',
        description:
            'Repository public methods must return Future<T> or Stream<T>.',
      );

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
    final path = context.definingUnit.file.path;
    if (!PathUtils.isInRepositories(path)) return;

    // NOTE: We pass context.allUnits to the visitor because definingUnit.content
    // only returns the LIBRARY file content, not part file (.g.dart) content.
    // The visitor must use allUnits to get the correct file's content.

    final visitor = _Visitor(this, context.allUnits);
    registry.addClassDeclaration(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AnalysisRule rule;
  final List<dynamic> allUnits;

  _Visitor(this.rule, this.allUnits);

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    // Skip generated files and nodes with ignore comments
    if (NodeContentHelper.shouldSkipNode(node, allUnits, rule.name)) return;

    for (final member in node.members) {
      if (member is MethodDeclaration) {
        _checkMethod(member);
      }
    }
  }

  void _checkMethod(MethodDeclaration method) {
    final methodName = method.name.lexeme;

    if (methodName.startsWith('_')) return;
    if (method.isGetter || method.isSetter) return;

    final returnType = method.returnType;
    if (returnType == null) return;

    final returnTypeName = returnType.toSource();

    final isValidReturn =
        returnTypeName.startsWith('Future<') ||
        returnTypeName.startsWith('Stream<') ||
        returnTypeName == 'Future' ||
        returnTypeName == 'Stream';

    if (!isValidReturn) {
      rule.reportAtNode(returnType);
    }
  }
}
