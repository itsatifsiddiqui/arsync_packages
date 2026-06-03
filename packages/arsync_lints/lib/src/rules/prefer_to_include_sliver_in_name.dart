import '../arsync_lint_rule.dart';

/// Lint rule: a widget whose `build()` returns a `Sliver*` widget should
/// include "Sliver" in its class name (or expose a `sliver*` named constructor).
class PreferToIncludeSliverInName extends AnalysisRule {
  PreferToIncludeSliverInName()
    : super(name: code.lowerCaseName, description: code.problemMessage);

  static const code = LintCode(
    'prefer_to_include_sliver_in_name',
    'Widgets returning Sliver should include "Sliver" '
        'in the class name or named constructor.',
    correctionMessage:
        'Add "Sliver" to the class name or use a named constructor with "sliver".',
  );

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    registry.addClassDeclaration(this, _Visitor(this));
  }
}

class _Visitor extends ArsyncRuleVisitor<AnalysisRule> {
  _Visitor(super.rule);

  @override
  void visitClassDeclaration(ClassDeclaration node) {

    final build = node.classMembers
        .whereType<MethodDeclaration>()
        .where((m) => m.name.lexeme == 'build')
        .firstOrNull;
    final body = build?.body;
    if (body is! BlockFunctionBody) return;
    if (!_returnsSliver(body.block)) return;

    if (node.className.lexeme.contains('Sliver')) return;

    final hasSliverConstructor = node.classMembers
        .whereType<ConstructorDeclaration>()
        .any(
          (c) => c.name?.lexeme.toLowerCase().contains('sliver') ?? false,
        );
    if (hasSliverConstructor) return;

    rule.reportAtNode(node);
  }

  static bool _returnsSliver(Block block) {
    for (final s in block.statements.whereType<ReturnStatement>()) {
      final type = s.expression?.staticType?.getDisplayString();
      if (type != null && type.startsWith('Sliver')) return true;
    }
    return false;
  }
}
