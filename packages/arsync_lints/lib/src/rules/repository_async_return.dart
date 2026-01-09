import 'package:analyzer/source/line_info.dart';

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
    if (!PathUtils.isInRepositories(path)) {
      return;
    }

    final content = context.definingUnit.content;
    final lineInfo = LineInfo.fromContent(content);

    final visitor = _Visitor(this, content, lineInfo);
    registry.addClassDeclaration(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AnalysisRule rule;
  final String content;
  final LineInfo lineInfo;

  _Visitor(this.rule, this.content, this.lineInfo);

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    for (final member in node.members) {
      if (member is MethodDeclaration) {
        _checkMethod(member);
      }
    }
  }

  void _checkMethod(MethodDeclaration method) {
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
      if (IgnoreUtils.shouldIgnoreAtOffset(
        offset: returnType.offset,
        lintName: 'repository_async_return',
        content: content,
        lineInfo: lineInfo,
      )) {
        return;
      }
      rule.reportAtNode(returnType);
    }
  }
}
