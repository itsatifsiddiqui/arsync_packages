import '../arsync_lint_rule.dart';

/// Rule A6: a `@freezed` class whose name ends with `State` and lives under
/// `lib/models/` should be in a `state/` subfolder (e.g.
/// `lib/models/<feature>/state/add_item_state.dart`).
///
/// Scope is intentionally narrow:
/// - Only `lib/models/`. State classes outside `models/` (e.g. ViewModel state
///   alongside providers) are not the target.
/// - The class must be `@freezed` and the name must end with `State`.
///   Both are required to keep false-positives low (an `EmptyState` widget
///   sentinel without freezed won't trigger).
/// - Files already under any `state/` folder are exempt.
class StateClassLocation extends AnalysisRule {
  StateClassLocation()
    : super(name: code.lowerCaseName, description: code.problemMessage);

  static const LintCode code = LintCode(
    'state_class_location',
    'Freezed state classes (named `*State`) should live under `state/` '
        '(typically `lib/models/<feature>/state/`).',
    correctionMessage:
        'Move this class to a `state/` folder to keep state classes organized.',
  );

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    final path = PathUtils.normalizePath(context.definingUnit.file.path);
    if (!PathUtils.isInModels(path)) return;
    // Already in a state folder — nothing to flag.
    if (path.contains('/state/')) return;
    registry.addClassDeclaration(this, _Visitor(this));
  }
}

class _Visitor extends ArsyncRuleVisitor<AnalysisRule> {
  _Visitor(super.rule);

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    if (!node.className.lexeme.endsWith('State')) return;
    if (!node.hasFreezedAnnotation) return;
    rule.reportAtOffset(node.className.offset, node.className.length);
  }
}
