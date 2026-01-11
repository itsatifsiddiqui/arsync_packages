import '../arsync_lint_rule.dart';

/// Rule: provider_state_class
///
/// Enforce state class conventions in provider files:
/// 1. State classes must be annotated with @freezed for immutability
/// 2. State classes must be defined in the same file (not imported from elsewhere)
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

  static bool isPrimitiveOrBuiltinType(String typeName) {
    const primitives = {
      'int',
      'double',
      'num',
      'String',
      'bool',
      'void',
      'dynamic',
      'Object',
      'Null',
      'Never',
      'List',
      'Map',
      'Set',
      'Future',
      'Stream',
      'Iterable',
      'AsyncValue',
      'Result',
    };
    return primitives.contains(typeName);
  }

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    final path = context.definingUnit.file.path;
    if (!PathUtils.isInProviders(path)) return;

    final content = context.definingUnit.content;
    final ignoreChecker = IgnoreChecker.forRule(content, name);
    if (ignoreChecker.ignoreForFile) return;

    final visitor = _Visitor(this, ignoreChecker);
    registry.addCompilationUnit(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final MultiAnalysisRule rule;
  final IgnoreChecker ignoreChecker;

  _Visitor(this.rule, this.ignoreChecker);

  @override
  void visitCompilationUnit(CompilationUnit node) {
    final definedClasses = <String>{};
    final stateClassUsages = <_StateClassUsage>[];
    final classDeclarations = <String, _ClassInfo>{};

    for (final declaration in node.declarations) {
      if (declaration is ClassDeclaration) {
        final className = declaration.name.lexeme;
        definedClasses.add(className);

        final hasFreezed = declaration.metadata.any((annotation) {
          final name = annotation.name.name;
          return name == 'freezed' || name == 'Freezed';
        });

        classDeclarations[className] = _ClassInfo(
          node: declaration,
          hasFreezed: hasFreezed,
        );

        final extendsClause = declaration.extendsClause;
        if (extendsClause != null) {
          final superclassName = extendsClause.superclass.name.lexeme;
          if (superclassName.contains('Notifier')) {
            final typeArgs = extendsClause.superclass.typeArguments;
            if (typeArgs != null && typeArgs.arguments.isNotEmpty) {
              final stateType = typeArgs.arguments.first;
              if (stateType is NamedType) {
                final stateTypeName = stateType.name.lexeme;
                if (!ProviderStateClass.isPrimitiveOrBuiltinType(
                  stateTypeName,
                )) {
                  stateClassUsages.add(
                    _StateClassUsage(
                      stateTypeName: stateTypeName,
                      notifierNode: declaration,
                      stateTypeNode: stateType,
                    ),
                  );
                }
              }
            }
          }
        }
      }
    }

    for (final usage in stateClassUsages) {
      final stateTypeName = usage.stateTypeName;
      final classInfo = classDeclarations[stateTypeName];

      // Only check classes with "State" in the name for being defined in the same file
      final isStateClass = stateTypeName.contains('State');

      if (classInfo == null) {
        // Only report if it's a State class that should be in the same file
        if (isStateClass) {
          if (!ignoreChecker.shouldIgnore(usage.stateTypeNode)) {
            rule.reportAtNode(
              usage.stateTypeNode,
              diagnosticCode: ProviderStateClass.importedStateCode,
            );
          }
        }
        continue;
      }

      // State classes must have @freezed
      if (isStateClass && !classInfo.hasFreezed) {
        if (!ignoreChecker.shouldIgnore(classInfo.node)) {
          rule.reportAtOffset(
            classInfo.node.name.offset,
            classInfo.node.name.length,
            diagnosticCode: ProviderStateClass.freezedCode,
          );
        }
      }
    }
  }
}

class _StateClassUsage {
  final String stateTypeName;
  final ClassDeclaration notifierNode;
  final NamedType stateTypeNode;

  _StateClassUsage({
    required this.stateTypeName,
    required this.notifierNode,
    required this.stateTypeNode,
  });
}

class _ClassInfo {
  final ClassDeclaration node;
  final bool hasFreezed;

  _ClassInfo({required this.node, required this.hasFreezed});
}
