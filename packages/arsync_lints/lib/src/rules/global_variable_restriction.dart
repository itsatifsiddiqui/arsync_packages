import '../arsync_lint_rule.dart';

/// Rule D2: global_variable_restriction
///
/// No global state pollution.
/// Variables allowed:
/// - Variables starting with _ (file-private)
/// - Variables starting with k (constants in constants.dart)
/// - Riverpod Providers (variables ending in Provider in lib/providers/ or lib/repositories/)
///
/// Functions allowed:
/// - Functions starting with _ (file-private)
/// - Functions starting with k (utility functions in constants.dart)
class GlobalVariableRestriction extends MultiAnalysisRule {
  GlobalVariableRestriction()
      : super(
          name: 'global_variable_restriction',
          description:
              'Top-level variables must be private (_), constants (k prefix in constants.dart), or Providers.',
        );

  static const variableCode = LintCode(
    'global_variable_restriction',
    'Top-level variables must be private (_), constants (k prefix in constants.dart), or Providers.',
    correctionMessage:
        'Make the variable private with _ prefix, move to constants.dart with k prefix, or use a Provider.',
  );

  static const functionCode = LintCode(
    'global_variable_restriction',
    'Top-level functions must be private (_) or defined in constants.dart with k prefix.',
    correctionMessage:
        'Make the function private with _ prefix, move to a class, or move to constants.dart with k prefix.',
  );

  @override
  List<DiagnosticCode> get diagnosticCodes => [variableCode, functionCode];

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    if (!context.isInLibDir) return;

    final content = context.definingUnit.content;
    final ignoreChecker = IgnoreChecker.forRule(content, name);
    if (ignoreChecker.ignoreForFile) return;

    final path = context.definingUnit.file.path;
    final isConstantsFile = PathUtils.isConstantsFile(path);
    final isProvidersFile = PathUtils.isInProviders(path);
    final isRepositoriesFile = PathUtils.isInRepositories(path);

    final visitor = _Visitor(this, ignoreChecker, isConstantsFile, isProvidersFile, isRepositoriesFile);
    registry.addTopLevelVariableDeclaration(this, visitor);
    registry.addFunctionDeclaration(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final MultiAnalysisRule rule;
  final IgnoreChecker ignoreChecker;
  final bool isConstantsFile;
  final bool isProvidersFile;
  final bool isRepositoriesFile;

  _Visitor(this.rule, this.ignoreChecker, this.isConstantsFile, this.isProvidersFile, this.isRepositoriesFile);

  @override
  void visitTopLevelVariableDeclaration(TopLevelVariableDeclaration node) {
    for (final variable in node.variables.variables) {
      final name = variable.name.lexeme;

      if (name.startsWith('_')) continue;
      if (isConstantsFile && name.startsWith('k')) continue;
      if (isProvidersFile && name.endsWith('Provider')) continue;
      if (isRepositoriesFile && name.endsWith('Provider')) continue;
      if (ignoreChecker.shouldIgnoreOffset(variable.name.offset)) continue;

      rule.reportAtOffset(
        variable.name.offset,
        variable.name.length,
        diagnosticCode: GlobalVariableRestriction.variableCode,
      );
    }
  }

  @override
  void visitFunctionDeclaration(FunctionDeclaration node) {
    if (node.parent is! CompilationUnit) return;

    final name = node.name.lexeme;

    if (name.startsWith('_')) return;
    if (isConstantsFile && name.startsWith('k')) return;
    if (name == 'main') return;
    if (ignoreChecker.shouldIgnore(node)) return;

    rule.reportAtOffset(
      node.name.offset,
      node.name.length,
      diagnosticCode: GlobalVariableRestriction.functionCode,
    );
  }
}
