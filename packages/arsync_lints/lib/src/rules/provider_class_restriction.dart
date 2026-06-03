import '../arsync_lint_rule.dart';

/// Rule: in `lib/providers/`, public classes must extend a `Notifier` variant
/// or be `@freezed` state classes.
class ProviderClassRestriction extends AnalysisRule {
  ProviderClassRestriction() : super(name: code.lowerCaseName, description: code.problemMessage);

  static const LintCode code = LintCode(
    'provider_class_restriction',
    'Provider files should only contain Notifier classes and @freezed state classes.',
    correctionMessage:
        'Move this class to the appropriate directory (models/, utils/, etc.) '
        'or add @freezed annotation if this is a state class.',
  );

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    if (!PathUtils.isInProviders(context.definingUnit.file.path)) return;
    registry.addClassDeclaration(this, _Visitor(this));
  }

}

class _Visitor extends ArsyncRuleVisitor<AnalysisRule> {
  _Visitor(super.rule);

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    if (node.className.lexeme.startsWith('_')) return;
    if (node.extendsNotifierVariant) return;
    if (node.hasFreezedAnnotation) return;
    rule.reportAtOffset(node.className.offset, node.className.length);
  }
}
