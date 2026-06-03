import '../arsync_lint_rule.dart';

/// Rule A3: models in `lib/models/` must be pure (no provider/screen imports),
/// annotated with `@freezed`, and expose a `fromJson` factory.
///
/// Path-based exemptions:
/// - `models/.../converters/` — `JsonConverter` / serializer helpers, fully
///   exempt (not models).
/// - `models/.../state/` — freezed state classes. The `@freezed` requirement
///   still applies, but the `fromJson` factory requirement is skipped since
///   state classes are typically not (de)serialized.
class ModelPurity extends MultiAnalysisRule {
  ModelPurity()
    : super(
        name: 'model_purity',
        description:
            'Models must be pure data structures without logic dependencies.',
      );

  static const importCode = LintCode(
    'model_purity',
    'Models must be pure data structures without logic dependencies.',
    correctionMessage: 'Remove logic or move it to a ViewModel.',
  );

  static const freezedCode = LintCode(
    'model_purity',
    'Models must be annotated with @freezed.',
    correctionMessage: 'Add the @freezed annotation to the class.',
  );

  static const fromJsonCode = LintCode(
    'model_purity',
    'Models must have a fromJson factory constructor.',
    correctionMessage: 'Add a factory ClassName.fromJson constructor.',
  );

  @override
  List<DiagnosticCode> get diagnosticCodes => [
    importCode,
    freezedCode,
    fromJsonCode,
  ];

  static const _bannedPatterns = [
    'providers/',
    'screens/',
    'package:flutter_riverpod',
    'package:riverpod',
    'package:hooks_riverpod',
  ];

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    final path = context.definingUnit.file.path;
    if (!PathUtils.isInModels(path)) return;
    final normalized = PathUtils.normalizePath(path);
    // Exempt JsonConverter / serializer helpers living under `converters/`.
    if (normalized.contains('/converters/')) return;
    // State classes don't need fromJson; we still enforce @freezed below.
    final inStateFolder = normalized.contains('/state/');

    registry
      ..addImportDirective(
        this,
        BannedImportVisitor(
          this,
          _bannedPatterns,
          (n) => reportAtNode(n, diagnosticCode: importCode),
        ),
      )
      ..addClassDeclaration(
        this,
        _Visitor(this, requireFromJson: !inStateFolder),
      );
  }

  static bool isBannedImport(String uri) => _bannedPatterns.any(uri.contains);
}

class _Visitor extends ArsyncRuleVisitor<MultiAnalysisRule> {
  _Visitor(super.rule, {required this.requireFromJson});

  final bool requireFromJson;

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    if (!node.hasFreezedAnnotation) {
      rule.reportAtOffset(
        node.className.offset,
        node.className.length,
        diagnosticCode: ModelPurity.freezedCode,
      );
    }

    if (!requireFromJson) return;

    final hasFromJson = node.classMembers.any(
      (m) =>
          m is ConstructorDeclaration &&
          m.factoryKeyword != null &&
          m.name?.lexeme == 'fromJson',
    );
    if (!hasFromJson) {
      rule.reportAtOffset(
        node.className.offset,
        node.className.length,
        diagnosticCode: ModelPurity.fromJsonCode,
      );
    }
  }
}
