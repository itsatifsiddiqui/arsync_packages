import 'package:analyzer/source/line_info.dart';

import '../arsync_lint_rule.dart';

/// Rule: provider_class_restriction
///
/// Provider files should only contain:
/// 1. Notifier classes (extending Notifier, AsyncNotifier, etc.)
/// 2. Freezed state classes (annotated with @freezed)
///
/// Any other class declarations (like plain models, helpers, etc.)
/// should be in their appropriate directories (models/, utils/, etc.)
class ProviderClassRestriction extends AnalysisRule {
  ProviderClassRestriction()
      : super(
          name: 'provider_class_restriction',
          description:
              'Provider files should only contain Notifier classes and @freezed state classes.',
        );

  static const LintCode code = LintCode(
    'provider_class_restriction',
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
  DiagnosticCode get diagnosticCode => code;

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
    final unit = context.definingUnit.unit;

    final visitor = _Visitor(this, content, lineInfo, unit);
    registry.addClassDeclaration(this, visitor);
  }

  /// Check if the class extends a Notifier base class
  static bool isNotifierClass(ClassDeclaration node) {
    final extendsClause = node.extendsClause;
    if (extendsClause == null) return false;

    final superclassName = extendsClause.superclass.name.lexeme;

    // Check if it matches any Notifier pattern
    return _notifierPatterns.any((pattern) => superclassName.contains(pattern));
  }

  /// Check if the class has @freezed annotation
  static bool hasFreezedAnnotation(ClassDeclaration node) {
    return node.metadata.any((annotation) {
      final name = annotation.name.name;
      return name == 'freezed' || name == 'Freezed';
    });
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AnalysisRule rule;
  final String content;
  final LineInfo lineInfo;
  final CompilationUnit unit;

  _Visitor(this.rule, this.content, this.lineInfo, this.unit);

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    final className = node.name.lexeme;

    // Skip private classes (they might be implementation details)
    if (className.startsWith('_')) return;

    // Check for ignore comments
    if (IgnoreUtils.shouldIgnore(
      node: node,
      lintName: 'provider_class_restriction',
      content: content,
      lineInfo: lineInfo,
      unit: unit,
    )) {
      return;
    }

    // Check if it's a Notifier class
    if (ProviderClassRestriction.isNotifierClass(node)) return;

    // Check if it has @freezed annotation
    if (ProviderClassRestriction.hasFreezedAnnotation(node)) return;

    // This class is not allowed in provider files
    rule.reportAtOffset(node.name.offset, node.name.length);
  }
}
