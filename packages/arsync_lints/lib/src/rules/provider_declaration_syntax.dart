import 'package:analyzer/source/line_info.dart';

import '../arsync_lint_rule.dart';

/// Rule: provider_declaration_syntax
///
/// Enforce clean provider declaration syntax:
/// 1. NotifierProvider must use .new constructor syntax (e.g., AuthNotifier.new)
/// 2. NotifierProvider must not have explicit generic type parameters
///
/// Good: `final authProvider = NotifierProvider.autoDispose(AuthNotifier.new);`
/// Bad:  `final authProvider = NotifierProvider.autoDispose<AuthNotifier, AuthState>(() => AuthNotifier());`
class ProviderDeclarationSyntax extends AnalysisRule {
  ProviderDeclarationSyntax()
      : super(
          name: 'provider_declaration_syntax',
          description:
              'NotifierProvider should use .new constructor syntax without explicit generic parameters.',
        );

  static const LintCode code = LintCode(
    'provider_declaration_syntax',
    'NotifierProvider should use .new constructor syntax without explicit generic parameters.',
    correctionMessage:
        'Use NotifierProvider.autoDispose(MyNotifier.new) instead of '
        'NotifierProvider.autoDispose<MyNotifier, State>(() => MyNotifier()).',
  );

  /// Provider types that should use .new syntax
  static const _notifierProviderTypes = {
    'NotifierProvider',
    'AsyncNotifierProvider',
    'StreamNotifierProvider',
  };

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    final path = context.definingUnit.file.path;
    if (!PathUtils.isInProviders(path)) {
      return;
    }

    final content = context.definingUnit.content;
    final lineInfo = LineInfo.fromContent(content);

    final visitor = _Visitor(this, content, lineInfo);
    registry.addTopLevelVariableDeclaration(this, visitor);
    registry.addFieldDeclaration(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AnalysisRule rule;
  final String content;
  final LineInfo lineInfo;

  _Visitor(this.rule, this.content, this.lineInfo);

  @override
  void visitTopLevelVariableDeclaration(TopLevelVariableDeclaration node) {
    for (final variable in node.variables.variables) {
      final initializer = variable.initializer;
      if (initializer == null) continue;

      _checkProviderSyntax(initializer);
    }
  }

  @override
  void visitFieldDeclaration(FieldDeclaration node) {
    for (final variable in node.fields.variables) {
      final initializer = variable.initializer;
      if (initializer == null) continue;

      _checkProviderSyntax(initializer);
    }
  }

  void _checkProviderSyntax(Expression initializer) {
    // Check if this is a NotifierProvider/AsyncNotifierProvider call with bad syntax
    final source = initializer.toSource();
    final isTargetedProvider = ProviderDeclarationSyntax._notifierProviderTypes.any(
      (type) => source.startsWith(type),
    );

    if (!isTargetedProvider) return;

    // Bad patterns:
    // 1. Has type args (like <A, B>) - should not have explicit generics
    // 2. Uses closure instead of .new - should use constructor tear-off
    final hasTypeArgs = source.contains('<') && source.contains('>');
    final usesClosureInsteadOfNew = !source.contains('.new') &&
        (source.contains('() {') || source.contains('() =>'));

    if (hasTypeArgs || usesClosureInsteadOfNew) {
      if (IgnoreUtils.shouldIgnoreAtOffset(
        offset: initializer.offset,
        lintName: 'provider_declaration_syntax',
        content: content,
        lineInfo: lineInfo,
      )) {
        return;
      }
      rule.reportAtNode(initializer);
    }
  }
}
