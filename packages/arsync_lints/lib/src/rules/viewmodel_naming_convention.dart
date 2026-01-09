import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

import '../utils.dart';

/// Rule B2: viewmodel_naming_convention
///
/// Enforce naming consistency for state management.
class ViewModelNamingConvention extends DartLintRule {
  const ViewModelNamingConvention() : super(code: _classCode);

  static const _classCode = LintCode(
    name: 'viewmodel_naming_convention',
    problemMessage:
        'Classes extending Notifier or AsyncNotifier must end with "Notifier".',
    correctionMessage: 'Rename the class to end with "Notifier".',
  );

  static const _providerCode = LintCode(
    name: 'viewmodel_naming_convention',
    problemMessage:
        'Provider variables must end with "Provider".',
    correctionMessage: 'Rename the variable to end with "Provider".',
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    // Only apply to files in lib/providers/
    if (!PathUtils.isInProviders(resolver.path)) {
      return;
    }

    // Check class names
    context.registry.addClassDeclaration((node) {
      final extendsClause = node.extendsClause;
      if (extendsClause == null) return;

      final superclassName = extendsClause.superclass.name2.lexeme;

      // Check if extending Notifier or AsyncNotifier
      if (superclassName.contains('Notifier') ||
          superclassName.contains('AsyncNotifier')) {
        final className = node.name.lexeme;

        if (!className.endsWith('Notifier')) {
          reporter.atToken(node.name, _classCode);
        }
      }
    });

    // Check provider variable names
    context.registry.addTopLevelVariableDeclaration((node) {
      for (final variable in node.variables.variables) {
        final initializer = variable.initializer;
        if (initializer == null) continue;

        final initializerSource = initializer.toSource();

        // Check if it's a provider (contains NotifierProvider, AsyncNotifierProvider, etc.)
        if (initializerSource.contains('Provider')) {
          final name = variable.name.lexeme;
          if (!name.endsWith('Provider')) {
            reporter.atToken(variable.name, _providerCode);
          }
        }
      }
    });
  }
}
