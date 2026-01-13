import '../arsync_lint_rule.dart';

/// Rule B2: viewmodel_naming_convention
///
/// Enforce naming consistency for state management.
class ViewModelNamingConvention extends MultiAnalysisRule {
  ViewModelNamingConvention()
    : super(
        name: 'viewmodel_naming_convention',
        description: 'Enforce naming conventions for ViewModels and providers.',
      );

  static const classCode = LintCode(
    'viewmodel_naming_convention',
    'Classes extending Notifier or AsyncNotifier must end with "Notifier".',
    correctionMessage: 'Rename the class to end with "Notifier".',
  );

  static const providerCode = LintCode(
    'viewmodel_naming_convention',
    'Provider variables must end with "Provider".',
    correctionMessage: 'Rename the variable to end with "Provider".',
  );

  @override
  List<DiagnosticCode> get diagnosticCodes => [classCode, providerCode];

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    final path = context.definingUnit.file.path;
    if (!PathUtils.isInProviders(path)) return;

    // NOTE: We pass context.allUnits to the visitor because definingUnit.content
    // only returns the LIBRARY file content, not part file (.g.dart) content.
    // The visitor must use allUnits to get the correct file's content.

    var visitor = _Visitor(this, context.allUnits);
    registry.addClassDeclaration(this, visitor);
    registry.addTopLevelVariableDeclaration(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final MultiAnalysisRule rule;
  final List<dynamic> allUnits;

  _Visitor(this.rule, this.allUnits);

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    // Skip generated files and nodes with ignore comments
    if (NodeContentHelper.shouldSkipNode(node, allUnits, rule.name)) return;

    final extendsClause = node.extendsClause;
    if (extendsClause == null) return;

    final superclassName = extendsClause.superclass.name.lexeme;
    if (superclassName.contains('Notifier') ||
        superclassName.contains('AsyncNotifier')) {
      final className = node.name.lexeme;
      if (!className.endsWith('Notifier')) {
        rule.reportAtOffset(
          node.name.offset,
          node.name.length,
          diagnosticCode: ViewModelNamingConvention.classCode,
        );
      }
    }
  }

  @override
  void visitTopLevelVariableDeclaration(TopLevelVariableDeclaration node) {
    // Skip generated files and nodes with ignore comments
    if (NodeContentHelper.shouldSkipNode(node, allUnits, rule.name)) return;

    for (final variable in node.variables.variables) {
      final initializer = variable.initializer;
      if (initializer == null) continue;

      final initializerSource = initializer.toSource();
      if (initializerSource.contains('Provider')) {
        final name = variable.name.lexeme;
        if (!name.endsWith('Provider')) {
          rule.reportAtOffset(
            variable.name.offset,
            variable.name.length,
            diagnosticCode: ViewModelNamingConvention.providerCode,
          );
        }
      }
    }
  }
}
