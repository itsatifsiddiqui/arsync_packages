import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../utils.dart';

/// Rule: provider_class_restriction
///
/// Provider files should only contain:
/// 1. Notifier classes (extending Notifier, AsyncNotifier, etc.)
/// 2. Freezed state classes (annotated with @freezed)
///
/// Any other class declarations (like plain models, helpers, etc.)
/// should be in their appropriate directories (models/, utils/, etc.)
class ProviderClassRestriction extends DartLintRule {
  const ProviderClassRestriction() : super(code: _code);

  static const _code = LintCode(
    name: 'provider_class_restriction',
    problemMessage:
        'Provider files should only contain Notifier classes and @freezed state classes.',
    correctionMessage:
        'Move this class to the appropriate directory (models/, utils/, etc.) '
        'or add @freezed annotation if this is a state class.',
  );

  /// Notifier base class patterns
  static const _notifierPatterns = {
    'Notifier',
    'AsyncNotifier',
    'StreamNotifier',
    'AutoDisposeNotifier',
    'AutoDisposeAsyncNotifier',
    'AutoDisposeStreamNotifier',
    'FamilyNotifier',
    'FamilyAsyncNotifier',
    'AutoDisposeFamilyNotifier',
    'AutoDisposeFamilyAsyncNotifier',
  };

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

    context.registry.addClassDeclaration((node) {
      final className = node.name.lexeme;

      // Skip private classes (they might be implementation details)
      if (className.startsWith('_')) return;

      // Check if it's a Notifier class
      if (_isNotifierClass(node)) return;

      // Check if it has @freezed annotation
      if (_hasFreezedAnnotation(node)) return;

      // This class is not allowed in provider files
      reporter.atToken(node.name, _code);
    });
  }

  /// Check if the class extends a Notifier base class
  bool _isNotifierClass(ClassDeclaration node) {
    final extendsClause = node.extendsClause;
    if (extendsClause == null) return false;

    final superclassName = extendsClause.superclass.name2.lexeme;

    // Check if it matches any Notifier pattern
    return _notifierPatterns.any((pattern) => superclassName.contains(pattern));
  }

  /// Check if the class has @freezed annotation
  bool _hasFreezedAnnotation(ClassDeclaration node) {
    return node.metadata.any((annotation) {
      final name = annotation.name.name;
      return name == 'freezed' || name == 'Freezed';
    });
  }
}
