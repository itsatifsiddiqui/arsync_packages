import 'package:analyzer/source/line_info.dart';

import '../arsync_lint_rule.dart';

/// Rule: provider_single_per_file
///
/// Each provider file should only contain ONE NotifierProvider that matches
/// the file name.
///
/// Good: auth_provider.dart contains only authProvider + AuthNotifier + AuthState
/// Bad: auth_provider.dart contains authProvider, userProvider, settingsProvider
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
  List<DiagnosticCode> get diagnosticCodes =>
      [multipleProvidersCode, nameMismatchCode];

  /// Provider type patterns to detect
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
    if (!PathUtils.isInProviders(path)) {
      return;
    }

    final fileName = PathUtils.getFileName(path);

    // Skip if file doesn't end with _provider
    if (!fileName.endsWith('_provider')) {
      return;
    }

    // Extract the expected provider name prefix (e.g., "auth" from "auth_provider")
    final prefix = fileName.replaceAll('_provider', '');
    final expectedProviderName = '${_snakeToCamel(prefix)}Provider';

    final content = context.definingUnit.content;
    final lineInfo = LineInfo.fromContent(content);

    final visitor = _Visitor(this, expectedProviderName, content, lineInfo);
    registry.addCompilationUnit(this, visitor);
  }

  /// Convert snake_case to camelCase
  static String _snakeToCamel(String snake) {
    final parts = snake.split('_');
    if (parts.isEmpty) return snake;

    final buffer = StringBuffer(parts.first);
    for (var i = 1; i < parts.length; i++) {
      if (parts[i].isNotEmpty) {
        buffer.write(parts[i][0].toUpperCase());
        buffer.write(parts[i].substring(1));
      }
    }
    return buffer.toString();
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final MultiAnalysisRule rule;
  final String expectedProviderName;
  final String content;
  final LineInfo lineInfo;

  _Visitor(this.rule, this.expectedProviderName, this.content, this.lineInfo);

  @override
  void visitCompilationUnit(CompilationUnit node) {
    // Collect all NotifierProvider declarations
    final providerDeclarations = <VariableDeclaration>[];

    for (final declaration in node.declarations) {
      if (declaration is TopLevelVariableDeclaration) {
        for (final variable in declaration.variables.variables) {
          final initializer = variable.initializer;
          if (initializer == null) continue;

          // Check if this is a NotifierProvider
          final source = initializer.toSource();
          final isNotifierProvider = ProviderSinglePerFile._providerPatterns.any(
            (pattern) => source.startsWith(pattern),
          );

          if (isNotifierProvider) {
            providerDeclarations.add(variable);
          }
        }
      }
    }

    if (providerDeclarations.isEmpty) return;

    // Check for multiple providers
    if (providerDeclarations.length > 1) {
      // Report on all providers after the first one
      for (var i = 1; i < providerDeclarations.length; i++) {
        if (IgnoreUtils.shouldIgnoreAtOffset(
          offset: providerDeclarations[i].name.offset,
          lintName: 'provider_single_per_file',
          content: content,
          lineInfo: lineInfo,
        )) {
          continue;
        }
        rule.reportAtOffset(
          providerDeclarations[i].name.offset,
          providerDeclarations[i].name.length,
          diagnosticCode: ProviderSinglePerFile.multipleProvidersCode,
        );
      }
    }

    // Check if the first/main provider matches the file name
    final mainProvider = providerDeclarations.first;
    final providerName = mainProvider.name.lexeme;

    if (providerName != expectedProviderName) {
      if (IgnoreUtils.shouldIgnoreAtOffset(
        offset: mainProvider.name.offset,
        lintName: 'provider_single_per_file',
        content: content,
        lineInfo: lineInfo,
      )) {
        return;
      }
      rule.reportAtOffset(
        mainProvider.name.offset,
        mainProvider.name.length,
        diagnosticCode: ProviderSinglePerFile.nameMismatchCode,
      );
    }
  }
}
