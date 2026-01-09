import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../utils.dart';

/// Rule A3: model_purity
///
/// Models are pure data structures. They cannot contain business logic or UI code.
/// Must be annotated with @freezed and have a fromJson factory.
class ModelPurity extends DartLintRule {
  const ModelPurity() : super(code: _importCode);

  static const _importCode = LintCode(
    name: 'model_purity',
    problemMessage:
        'Models must be pure data structures without logic dependencies.',
    correctionMessage: 'Remove logic or move it to a ViewModel.',
  );

  static const _freezedCode = LintCode(
    name: 'model_purity',
    problemMessage: 'Models must be annotated with @freezed.',
    correctionMessage: 'Add the @freezed annotation to the class.',
  );

  static const _fromJsonCode = LintCode(
    name: 'model_purity',
    problemMessage: 'Models must have a fromJson factory constructor.',
    correctionMessage: 'Add a factory ClassName.fromJson constructor.',
  );

  /// Banned import patterns for models.
  static const _bannedPatterns = [
    'providers/',
    'screens/',
    'package:flutter_riverpod',
    'package:riverpod',
    'package:hooks_riverpod',
  ];

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    // Only apply to files in lib/models/
    if (!PathUtils.isInModels(resolver.path)) {
      return;
    }

    // Check for banned imports
    context.registry.addImportDirective((node) {
      final importUri = node.uri.stringValue;
      if (importUri == null) return;

      if (_isBannedImport(importUri)) {
        reporter.atNode(node, _importCode);
      }
    });

    // Check for @freezed annotation and fromJson factory
    context.registry.addClassDeclaration((node) {
      // Check for @freezed annotation
      final hasFreezed = node.metadata.any((annotation) {
        final name = annotation.name.name;
        return name == 'freezed' || name == 'Freezed';
      });

      if (!hasFreezed) {
        reporter.atToken(node.name, _freezedCode);
      }

      // Check for fromJson factory
      final hasFromJson = node.members.any((member) {
        if (member is ConstructorDeclaration) {
          return member.factoryKeyword != null && member.name?.lexeme == 'fromJson';
        }
        return false;
      });

      if (!hasFromJson) {
        reporter.atToken(node.name, _fromJsonCode);
      }
    });
  }

  bool _isBannedImport(String importUri) {
    for (final pattern in _bannedPatterns) {
      if (importUri.contains(pattern)) {
        return true;
      }
    }
    return false;
  }
}
