import '../arsync_lint_rule.dart';

/// Rule D2: top-level variables and functions must be private (`_`), `k`-prefixed
/// constants inside `constants.dart`, Riverpod providers in `lib/providers/` or
/// `lib/repositories/`, or `main()`.
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
    final path = context.definingUnit.file.path;
    final visitor = _Visitor(
      this,
      isConstantsFile: PathUtils.isConstantsFile(path),
      isProvidersFile: PathUtils.isInProviders(path),
      isRepositoriesFile: PathUtils.isInRepositories(path),
    );
    registry
      ..addTopLevelVariableDeclaration(this, visitor)
      ..addFunctionDeclaration(this, visitor);
  }
}

class _Visitor extends ArsyncRuleVisitor<MultiAnalysisRule> {
  final bool isConstantsFile;
  final bool isProvidersFile;
  final bool isRepositoriesFile;

  _Visitor(
    super.rule, {
    required this.isConstantsFile,
    required this.isProvidersFile,
    required this.isRepositoriesFile,
  });

  bool get _providerNameAllowed => isProvidersFile || isRepositoriesFile;

  @override
  void visitTopLevelVariableDeclaration(TopLevelVariableDeclaration node) {

    for (final v in node.variables.variables) {
      final name = v.name.lexeme;
      if (name.startsWith('_')) continue;
      if (isConstantsFile && name.startsWith('k')) continue;
      if (_providerNameAllowed && name.endsWith('Provider')) continue;

      rule.reportAtOffset(
        v.name.offset,
        v.name.length,
        diagnosticCode: GlobalVariableRestriction.variableCode,
      );
    }
  }

  @override
  void visitFunctionDeclaration(FunctionDeclaration node) {
    if (node.parent is! CompilationUnit) return;

    final name = node.name.lexeme;
    if (name.startsWith('_') || name == 'main') return;
    if (isConstantsFile && name.startsWith('k')) return;

    rule.reportAtOffset(
      node.name.offset,
      node.name.length,
      diagnosticCode: GlobalVariableRestriction.functionCode,
    );
  }
}
