import '../arsync_lint_rule.dart';

/// Rule: provider_file_naming
///
/// Enforce naming conventions in providers directory:
/// - File names must end with _provider.dart (e.g., auth_provider.dart)
/// - File must contain a Notifier class with matching prefix (e.g., AuthNotifier)
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

    // NOTE: We pass context.allUnits to the visitor because definingUnit.content
    // only returns the LIBRARY file content, not part file (.g.dart) content.
    // The visitor must use allUnits to get the correct file's content.

    final visitor = _Visitor(this, context.allUnits, fileName);
    registry.addCompilationUnit(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final MultiAnalysisRule rule;
  final List<dynamic> allUnits;
  final String fileName;

  _Visitor(this.rule, this.allUnits, this.fileName);

  @override
  void visitCompilationUnit(CompilationUnit node) {
    // Skip generated files and nodes with ignore comments
    if (NodeContentHelper.shouldSkipNode(node, allUnits, rule.name)) return;

    if (!fileName.endsWith('_provider')) {
      for (final declaration in node.declarations) {
        if (declaration is ClassDeclaration &&
            !declaration.name.lexeme.startsWith('_')) {
          rule.reportAtOffset(
            declaration.name.offset,
            declaration.name.length,
            diagnosticCode: ProviderFileNaming.fileCode,
          );
          break;
        }
      }
      return;
    }

    final prefix = fileName.replaceAll('_provider', '');
    final expectedNotifierPrefix = PathUtils.snakeToPascal(prefix);

    final notifierClasses = <String>[];
    ClassDeclaration? firstPublicClass;

    for (final declaration in node.declarations) {
      if (declaration is ClassDeclaration) {
        final className = declaration.name.lexeme;
        if (className.startsWith('_')) continue;

        firstPublicClass ??= declaration;

        final extendsClause = declaration.extendsClause;
        if (extendsClause != null) {
          final superclassName = extendsClause.superclass.name.lexeme;
          if (superclassName.contains('Notifier')) {
            notifierClasses.add(className);
          }
        }
      }
    }

    if (notifierClasses.isNotEmpty) {
      final hasMatchingNotifier = notifierClasses.any(
        (name) =>
            name.startsWith(expectedNotifierPrefix) &&
            name.endsWith('Notifier'),
      );

      if (!hasMatchingNotifier && firstPublicClass != null) {
        rule.reportAtOffset(
          firstPublicClass.name.offset,
          firstPublicClass.name.length,
          diagnosticCode: ProviderFileNaming.notifierMissingCode,
        );
      }
    }
  }
}
