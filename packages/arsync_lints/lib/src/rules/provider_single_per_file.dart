import '../arsync_lint_rule.dart';

/// Rule: a `_provider.dart` file should contain exactly one
/// `NotifierProvider`-style top-level variable whose name matches the file
/// (e.g. `auth_provider.dart` → `authProvider`).
class ProviderSinglePerFile extends MultiAnalysisRule {
  ProviderSinglePerFile()
    : super(
        name: 'provider_single_per_file',
        description:
            'Provider file should only contain ONE NotifierProvider that matches file name.',
      );

  static const multipleProvidersCode = LintCode(
    'provider_single_per_file',
    'Provider file should only contain ONE NotifierProvider. '
        'Move additional providers to their own files.',
    correctionMessage:
        'Create a separate file for this provider (e.g., user_provider.dart for userProvider).',
  );

  static const nameMismatchCode = LintCode(
    'provider_single_per_file',
    'Provider variable name does not match file name.',
    correctionMessage:
        'Rename the provider to match the file name '
        '(e.g., auth_provider.dart should have authProvider).',
  );

  @override
  List<DiagnosticCode> get diagnosticCodes => [
    multipleProvidersCode,
    nameMismatchCode,
  ];

  static const _providerPatterns = {
    'NotifierProvider',
    'AsyncNotifierProvider',
    'StreamNotifierProvider',
  };

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    final path = context.definingUnit.file.path;
    if (!PathUtils.isInProviders(path)) return;
    final fileName = PathUtils.getFileName(path);
    if (!fileName.endsWith('_provider')) return;

    final expected =
        '${PathUtils.snakeToCamel(fileName.replaceAll('_provider', ''))}Provider';
    registry.addCompilationUnit(
      this,
      _Visitor(this, expected),
    );
  }
}

class _Visitor extends ArsyncRuleVisitor<MultiAnalysisRule> {
  final String expectedProviderName;

  _Visitor(super.rule, this.expectedProviderName);

  @override
  void visitCompilationUnit(CompilationUnit node) {
    final providers = [
      for (final d in node.declarations.whereType<TopLevelVariableDeclaration>())
        for (final v in d.variables.variables)
          if (_isNotifierProvider(v.initializer)) v,
    ];
    if (providers.isEmpty) return;

    for (final extra in providers.skip(1)) {
      rule.reportAtOffset(
        extra.name.offset,
        extra.name.length,
        diagnosticCode: ProviderSinglePerFile.multipleProvidersCode,
      );
    }

    final main = providers.first;
    if (main.name.lexeme != expectedProviderName) {
      rule.reportAtOffset(
        main.name.offset,
        main.name.length,
        diagnosticCode: ProviderSinglePerFile.nameMismatchCode,
      );
    }
  }

  /// True if [initializer] is a `NotifierProvider` / `AsyncNotifierProvider` /
  /// `StreamNotifierProvider` constructor call (named or unnamed).
  static bool _isNotifierProvider(Expression? initializer) {
    if (initializer is! InstanceCreationExpression) return false;
    return ProviderSinglePerFile._providerPatterns.contains(initializer.typeName);
  }
}
