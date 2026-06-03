import '../arsync_lint_rule.dart';

/// Rule: files in `lib/providers/` must end with `_provider.dart` and contain
/// a `Notifier` class with a matching prefix (e.g. `auth_provider.dart` →
/// `AuthNotifier`).
class ProviderFileNaming extends MultiAnalysisRule {
  ProviderFileNaming()
    : super(
        name: 'provider_file_naming',
        description:
            'Provider files must end with _provider.dart and contain a matching Notifier class.',
      );

  static const fileCode = LintCode(
    'provider_file_naming',
    'Provider files must end with _provider.dart and contain a matching Notifier class.',
    correctionMessage:
        'Rename file to {name}_provider.dart and ensure it has a {Name}Notifier class.',
  );

  static const notifierMissingCode = LintCode(
    'provider_file_naming',
    'Provider file must contain a Notifier class with matching prefix (e.g., auth_provider.dart should have AuthNotifier).',
    correctionMessage:
        'Add a Notifier class that matches the file name prefix (e.g., AuthNotifier for auth_provider.dart).',
  );

  @override
  List<DiagnosticCode> get diagnosticCodes => [fileCode, notifierMissingCode];

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    final path = context.definingUnit.file.path;
    if (!PathUtils.isInProviders(path)) return;
    final fileName = PathUtils.getFileName(path);
    if (fileName == 'index' || fileName.startsWith('_')) return;

    registry.addCompilationUnit(
      this,
      _Visitor(this, fileName),
    );
  }
}

class _Visitor extends ArsyncRuleVisitor<MultiAnalysisRule> {
  final String fileName;

  _Visitor(super.rule, this.fileName);

  @override
  void visitCompilationUnit(CompilationUnit node) {

    final publics = node.declarations
        .whereType<ClassDeclaration>()
        .where((d) => !d.className.lexeme.startsWith('_'))
        .toList();

    if (!fileName.endsWith('_provider')) {
      if (publics.isNotEmpty) {
        rule.reportAtOffset(
          publics.first.className.offset,
          publics.first.className.length,
          diagnosticCode: ProviderFileNaming.fileCode,
        );
      }
      return;
    }

    final expectedPrefix = PathUtils.snakeToPascal(
      fileName.replaceAll('_provider', ''),
    );

    final notifiers = [
      for (final d in publics)
        if (d.extendsNotifierVariant) d.className.lexeme,
    ];
    if (notifiers.isEmpty || publics.isEmpty) return;

    final hasMatch = notifiers.any(
      (n) => n.startsWith(expectedPrefix) && n.endsWith('Notifier'),
    );
    if (!hasMatch) {
      rule.reportAtOffset(
        publics.first.className.offset,
        publics.first.className.length,
        diagnosticCode: ProviderFileNaming.notifierMissingCode,
      );
    }
  }
}
