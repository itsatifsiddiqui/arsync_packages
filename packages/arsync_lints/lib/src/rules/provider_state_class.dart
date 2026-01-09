import 'package:analyzer/source/line_info.dart';

import '../arsync_lint_rule.dart';

/// Rule: provider_state_class
///
/// Enforce state class conventions in provider files:
/// 1. State classes must be annotated with @freezed for immutability
/// 2. State classes must be defined in the same file (not imported from elsewhere)
///
/// Note: Private state classes are not enforced because freezed code generation
/// doesn't work well with private class names (e.g., _AuthState conflicts with
/// generated _$AuthState mixin naming).
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

  /// Check if a type name is a primitive or built-in type that doesn't need validation
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
      // Common generic types
      'List',
      'Map',
      'Set',
      'Future',
      'Stream',
      'Iterable',
      // Common Flutter/Dart types
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
    if (!PathUtils.isInProviders(path)) {
      return;
    }

    final content = context.definingUnit.content;
    final lineInfo = LineInfo.fromContent(content);

    final visitor = _Visitor(this, content, lineInfo);
    registry.addCompilationUnit(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final MultiAnalysisRule rule;
  final String content;
  final LineInfo lineInfo;

  _Visitor(this.rule, this.content, this.lineInfo);

  @override
  void visitCompilationUnit(CompilationUnit node) {
    // Collect all class names defined in this file
    final definedClasses = <String>{};
    // Collect all state classes used by Notifiers
    final stateClassUsages = <_StateClassUsage>[];
    // Collect all class declarations with their metadata
    final classDeclarations = <String, _ClassInfo>{};

    for (final declaration in node.declarations) {
      if (declaration is ClassDeclaration) {
        final className = declaration.name.lexeme;
        definedClasses.add(className);

        // Check if class has @freezed annotation
        final hasFreezed = declaration.metadata.any((annotation) {
          final name = annotation.name.name;
          return name == 'freezed' || name == 'Freezed';
        });

        classDeclarations[className] = _ClassInfo(
          node: declaration,
          hasFreezed: hasFreezed,
        );

        // Check if this is a Notifier class
        final extendsClause = declaration.extendsClause;
        if (extendsClause != null) {
          final superclassName = extendsClause.superclass.name.lexeme;
          if (superclassName.contains('Notifier')) {
            // Extract the state type from the generic parameter
            final typeArgs = extendsClause.superclass.typeArguments;
            if (typeArgs != null && typeArgs.arguments.isNotEmpty) {
              final stateType = typeArgs.arguments.first;
              if (stateType is NamedType) {
                final stateTypeName = stateType.name.lexeme;
                // Skip primitive types and common non-state types
                if (!ProviderStateClass.isPrimitiveOrBuiltinType(
                    stateTypeName)) {
                  stateClassUsages.add(_StateClassUsage(
                    stateTypeName: stateTypeName,
                    notifierNode: declaration,
                    stateTypeNode: stateType,
                  ));
                }
              }
            }
          }
        }
      }
    }

    // Validate state classes
    for (final usage in stateClassUsages) {
      final stateTypeName = usage.stateTypeName;
      final classInfo = classDeclarations[stateTypeName];

      if (classInfo == null) {
        // State class is not defined in this file (imported)
        if (IgnoreUtils.shouldIgnoreAtOffset(
          offset: usage.stateTypeNode.offset,
          lintName: 'provider_state_class',
          content: content,
          lineInfo: lineInfo,
        )) {
          continue;
        }
        rule.reportAtNode(
            usage.stateTypeNode, diagnosticCode: ProviderStateClass.importedStateCode);
        continue;
      }

      // Check if state class has @freezed annotation
      if (!classInfo.hasFreezed) {
        if (IgnoreUtils.shouldIgnoreAtOffset(
          offset: classInfo.node.name.offset,
          lintName: 'provider_state_class',
          content: content,
          lineInfo: lineInfo,
        )) {
          continue;
        }
        rule.reportAtOffset(
          classInfo.node.name.offset,
          classInfo.node.name.length,
          diagnosticCode: ProviderStateClass.freezedCode,
        );
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

  _ClassInfo({
    required this.node,
    required this.hasFreezed,
  });
}
