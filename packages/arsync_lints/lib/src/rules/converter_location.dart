import '../arsync_lint_rule.dart';

/// Rule A5: any class that `implements JsonConverter<...>` should live under
/// a `converters/` folder (typically `lib/models/converters/`). Keeps
/// serialization helpers organized alongside the models they belong to.
class ConverterLocation extends AnalysisRule {
  ConverterLocation()
    : super(name: code.lowerCaseName, description: code.problemMessage);

  static const LintCode code = LintCode(
    'converter_location',
    'JsonConverter implementations should live under `converters/` '
        '(typically `lib/models/converters/`).',
    correctionMessage:
        'Move this class to `lib/models/converters/` to keep '
        'serializers organized.',
  );

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    if (!context.isInLibDir) return;
    final path = PathUtils.normalizePath(context.definingUnit.file.path);
    // Already in a converters folder — nothing to flag.
    if (path.contains('/converters/')) return;
    registry.addClassDeclaration(this, _Visitor(this));
  }
}

class _Visitor extends ArsyncRuleVisitor<AnalysisRule> {
  _Visitor(super.rule);

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    final implementsClause = node.implementsClause;
    if (implementsClause == null) return;
    final implementsJsonConverter = implementsClause.interfaces.any(
      (t) => t.name.lexeme == 'JsonConverter',
    );
    if (!implementsJsonConverter) return;
    rule.reportAtOffset(node.className.offset, node.className.length);
  }
}
