import '../arsync_lint_rule.dart';

/// Rule: state classes referenced by `NotifierProvider`-style classes in
/// `lib/providers/` must be `@freezed` and defined in the same file.
class ProviderStateClass extends MultiAnalysisRule {
  ProviderStateClass()
    : super(
        name: 'provider_state_class',
        description:
            'State classes must be @freezed and defined in the same provider file.',
      );

  static const freezedCode = LintCode(
    'provider_state_class',
    'State class must be annotated with @freezed.',
    correctionMessage:
        'Add @freezed annotation to the state class for immutability and copyWith support.',
  );

  static const importedStateCode = LintCode(
    'provider_state_class',
    'State class must be defined in the same provider file, not imported.',
    correctionMessage:
        'Move the state class definition into this provider file as a freezed class.',
  );

  @override
  List<DiagnosticCode> get diagnosticCodes => [freezedCode, importedStateCode];

  static const _builtinTypes = {
    'int', 'double', 'num', 'String', 'bool', 'void', 'dynamic',
    'Object', 'Null', 'Never',
    'List', 'Map', 'Set', 'Future', 'Stream', 'Iterable',
    'AsyncValue', 'Result',
  };

  static bool isPrimitiveOrBuiltinType(String typeName) =>
      _builtinTypes.contains(typeName);

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    if (!PathUtils.isInProviders(context.definingUnit.file.path)) return;
    registry.addCompilationUnit(this, _Visitor(this));
  }
}

class _Visitor extends ArsyncRuleVisitor<MultiAnalysisRule> {
  _Visitor(super.rule);

  @override
  void visitCompilationUnit(CompilationUnit node) {

    final classes = <String, ClassDeclaration>{};
    final stateUsages = <(String name, NamedType node)>[];

    for (final decl in node.declarations.whereType<ClassDeclaration>()) {
      classes[decl.className.lexeme] = decl;

      if (!decl.extendsNotifierVariant) continue;
      final stateType =
          decl.extendsClause!.superclass.typeArguments?.arguments.firstOrNull;
      if (stateType is! NamedType) continue;
      final name = stateType.name.lexeme;
      if (ProviderStateClass.isPrimitiveOrBuiltinType(name)) continue;
      stateUsages.add((name, stateType));
    }

    for (final (name, typeNode) in stateUsages) {
      final classDecl = classes[name];
      final isStateClass = name.contains('State');
      if (!isStateClass) continue;

      if (classDecl == null) {
        rule.reportAtNode(
          typeNode,
          diagnosticCode: ProviderStateClass.importedStateCode,
        );
        continue;
      }

      if (!classDecl.hasFreezedAnnotation) {
        rule.reportAtOffset(
          classDecl.className.offset,
          classDecl.className.length,
          diagnosticCode: ProviderStateClass.freezedCode,
        );
      }
    }
  }
}
