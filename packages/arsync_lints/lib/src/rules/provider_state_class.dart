import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../utils.dart';

/// Rule: provider_state_class
///
/// Enforce state class conventions in provider files:
/// 1. State classes must be annotated with @freezed for immutability
/// 2. State classes must be defined in the same file (not imported from elsewhere)
///
/// Note: Private state classes are not enforced because freezed code generation
/// doesn't work well with private class names (e.g., _AuthState conflicts with
/// generated _$AuthState mixin naming).
class ProviderStateClass extends DartLintRule {
  const ProviderStateClass() : super(code: _freezedCode);

  static const _freezedCode = LintCode(
    name: 'provider_state_class',
    problemMessage: 'State class must be annotated with @freezed.',
    correctionMessage:
        'Add @freezed annotation to the state class for immutability and copyWith support.',
  );

  static const _importedStateCode = LintCode(
    name: 'provider_state_class',
    problemMessage:
        'State class must be defined in the same provider file, not imported.',
    correctionMessage:
        'Move the state class definition into this provider file as a freezed class.',
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    // Only apply to files in providers directory
    if (!PathUtils.isInProviders(resolver.path)) {
      return;
    }

    // Collect all class names defined in this file
    final definedClasses = <String>{};
    // Collect all state classes used by Notifiers
    final stateClassUsages = <_StateClassUsage>[];
    // Collect all class declarations with their metadata
    final classDeclarations = <String, _ClassInfo>{};

    // First pass: collect all defined classes and their annotations
    context.registry.addClassDeclaration((node) {
      final className = node.name.lexeme;
      definedClasses.add(className);

      // Check if class has @freezed annotation
      final hasFreezed = node.metadata.any((annotation) {
        final name = annotation.name.name;
        return name == 'freezed' || name == 'Freezed';
      });

      classDeclarations[className] = _ClassInfo(
        node: node,
        hasFreezed: hasFreezed,
      );

      // Check if this is a Notifier class
      final extendsClause = node.extendsClause;
      if (extendsClause != null) {
        final superclassName = extendsClause.superclass.name2.lexeme;
        if (superclassName.contains('Notifier')) {
          // Extract the state type from the generic parameter
          final typeArgs = extendsClause.superclass.typeArguments;
          if (typeArgs != null && typeArgs.arguments.isNotEmpty) {
            final stateType = typeArgs.arguments.first;
            if (stateType is NamedType) {
              final stateTypeName = stateType.name2.lexeme;
              // Skip primitive types and common non-state types
              if (!_isPrimitiveOrBuiltinType(stateTypeName)) {
                stateClassUsages.add(_StateClassUsage(
                  stateTypeName: stateTypeName,
                  notifierNode: node,
                  stateTypeNode: stateType,
                ));
              }
            }
          }
        }
      }
    });

    // After all classes are collected, validate state classes
    context.addPostRunCallback(() {
      for (final usage in stateClassUsages) {
        final stateTypeName = usage.stateTypeName;
        final classInfo = classDeclarations[stateTypeName];

        if (classInfo == null) {
          // State class is not defined in this file (imported)
          reporter.atNode(usage.stateTypeNode, _importedStateCode);
          continue;
        }

        // Check if state class has @freezed annotation
        if (!classInfo.hasFreezed) {
          reporter.atToken(classInfo.node.name, _freezedCode);
        }
      }
    });
  }

  /// Check if a type name is a primitive or built-in type that doesn't need validation
  bool _isPrimitiveOrBuiltinType(String typeName) {
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
