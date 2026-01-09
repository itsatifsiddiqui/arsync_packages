import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../utils.dart';

/// Rule A1: presentation_layer_isolation
///
/// Files in lib/screens/ and lib/widgets/ cannot import Infrastructure,
/// Repositories, or Data Sources.
/// Also enforces: use Dart records instead of plain parameter classes.
class PresentationLayerIsolation extends DartLintRule {
  const PresentationLayerIsolation() : super(code: _importCode);

  static const _importCode = LintCode(
    name: 'presentation_layer_isolation',
    problemMessage:
        'Presentation Layer cannot touch Repositories or Data Sources directly. '
        'Use a ViewModel.',
    correctionMessage:
        'Move logic to a ViewModel (Provider) and watch the provider instead.',
  );

  static const _useRecordCode = LintCode(
    name: 'presentation_layer_isolation',
    problemMessage:
        'Use Dart records instead of plain parameter classes in presentation layer.',
    correctionMessage:
        'Replace with a record type: typedef ParamsName = ({Type field1, Type field2});',
  );

  /// Banned import patterns for presentation layer.
  static const _bannedPatterns = [
    'repositories/',
    'package:cloud_firestore',
    'package:http/',
    'package:http',
    'package:dio/',
    'package:dio',
  ];

  /// Widget base classes that are allowed
  static const _allowedBaseClasses = {
    'StatelessWidget',
    'StatefulWidget',
    'HookWidget',
    'HookConsumerWidget',
    'ConsumerWidget',
    'ConsumerStatefulWidget',
    'State',
  };

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    // Only apply to files in lib/screens/ or lib/widgets/
    if (!PathUtils.isInScreens(resolver.path) &&
        !PathUtils.isInWidgets(resolver.path)) {
      return;
    }

    // Check imports
    context.registry.addImportDirective((node) {
      final importUri = node.uri.stringValue;
      if (importUri == null) return;

      if (_isBannedImport(importUri)) {
        reporter.atNode(node, _importCode);
      }
    });

    // Check for plain parameter classes (should use records)
    context.registry.addClassDeclaration((node) {
      final className = node.name.lexeme;

      // Skip private classes
      if (className.startsWith('_')) return;

      // Skip widget classes
      if (_isWidgetClass(node)) return;

      // Check if it looks like a parameter/data class
      if (_isParameterClass(node)) {
        reporter.atToken(node.name, _useRecordCode);
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

  /// Check if class extends a Widget
  bool _isWidgetClass(ClassDeclaration node) {
    final extendsClause = node.extendsClause;
    if (extendsClause == null) return false;

    final superclassName = extendsClause.superclass.name2.lexeme;
    return _allowedBaseClasses.contains(superclassName);
  }

  /// Check if class is a simple parameter/data class
  /// (only has final fields and constructor, no methods)
  bool _isParameterClass(ClassDeclaration node) {
    final members = node.members;

    bool hasOnlyFinalFields = true;
    bool hasConstructor = false;
    bool hasMethods = false;

    for (final member in members) {
      if (member is FieldDeclaration) {
        // Check if all fields are final
        if (!member.fields.isFinal) {
          hasOnlyFinalFields = false;
        }
      } else if (member is ConstructorDeclaration) {
        hasConstructor = true;
      } else if (member is MethodDeclaration) {
        // Has methods - not a simple parameter class
        hasMethods = true;
      }
    }

    // It's a parameter class if:
    // - Has a constructor
    // - Has only final fields
    // - Has no methods (except maybe getters from fields)
    return hasConstructor && hasOnlyFinalFields && !hasMethods;
  }
}
