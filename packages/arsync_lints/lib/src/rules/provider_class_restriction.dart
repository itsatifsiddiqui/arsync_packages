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
    if (!PathUtils.isInProviders(path)) return;

    final content = context.definingUnit.content;
    final ignoreChecker = IgnoreChecker.forRule(content, name);
    if (ignoreChecker.ignoreForFile) return;

    final visitor = _Visitor(this, ignoreChecker);
    registry.addClassDeclaration(this, visitor);
  }

  static bool isNotifierClass(ClassDeclaration node) {
    final extendsClause = node.extendsClause;
    if (extendsClause == null) return false;
    final superclassName = extendsClause.superclass.name.lexeme;
    return _notifierPatterns.any((pattern) => superclassName.contains(pattern));
  }

  static bool hasFreezedAnnotation(ClassDeclaration node) {
    return node.metadata.any((annotation) {
      final name = annotation.name.name;
      return name == 'freezed' || name == 'Freezed';
    });
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final AnalysisRule rule;
  final IgnoreChecker ignoreChecker;

  _Visitor(this.rule, this.ignoreChecker);

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    if (ignoreChecker.shouldIgnore(node)) return;

    final className = node.name.lexeme;
    if (className.startsWith('_')) return;

    if (ProviderClassRestriction.isNotifierClass(node)) return;
    if (ProviderClassRestriction.hasFreezedAnnotation(node)) return;

    rule.reportAtOffset(node.name.offset, node.name.length);
  }
}
