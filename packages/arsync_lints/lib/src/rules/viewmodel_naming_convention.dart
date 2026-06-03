import '../arsync_lint_rule.dart';

/// Rule B2: in `lib/providers/`, classes extending `Notifier`/`AsyncNotifier`
/// must be named `*Notifier`, and top-level provider variables must be named
/// `*Provider`.
class ViewModelNamingConvention extends MultiAnalysisRule {
  ViewModelNamingConvention()
    : super(
        name: 'viewmodel_naming_convention',
        description: 'Enforce naming conventions for ViewModels and providers.',
      );

  static const classCode = LintCode(
    'viewmodel_naming_convention',
    'Classes extending Notifier or AsyncNotifier must end with "Notifier".',
    correctionMessage: 'Rename the class to end with "Notifier".',
  );

  static const providerCode = LintCode(
    'viewmodel_naming_convention',
    'Provider variables must end with "Provider".',
    correctionMessage: 'Rename the variable to end with "Provider".',
  );

  @override
  List<DiagnosticCode> get diagnosticCodes => [classCode, providerCode];

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    if (!PathUtils.isInProviders(context.definingUnit.file.path)) return;
    final visitor = _Visitor(this);
    registry
      ..addClassDeclaration(this, visitor)
      ..addTopLevelVariableDeclaration(this, visitor);
  }
}

class _Visitor extends ArsyncRuleVisitor<MultiAnalysisRule> {
  _Visitor(super.rule);

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    if (!node.extendsNotifierVariant) return;
    if (node.className.lexeme.endsWith('Notifier')) return;
    rule.reportAtOffset(
      node.className.offset,
      node.className.length,
      diagnosticCode: ViewModelNamingConvention.classCode,
    );
  }

  @override
  void visitTopLevelVariableDeclaration(TopLevelVariableDeclaration node) {

    for (final v in node.variables.variables) {
      final init = v.initializer?.toSource();
      if (init == null || !init.contains('Provider')) continue;
      if (v.name.lexeme.endsWith('Provider')) continue;
      rule.reportAtOffset(
        v.name.offset,
        v.name.length,
        diagnosticCode: ViewModelNamingConvention.providerCode,
      );
    }
  }
}
