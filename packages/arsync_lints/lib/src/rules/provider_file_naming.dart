import 'package:analyzer/source/line_info.dart';

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
    if (!PathUtils.isInProviders(path)) {
      return;
    }

    final fileName = PathUtils.getFileName(path);

    // Skip index.dart and other special files
    if (fileName == 'index' || fileName.startsWith('_')) {
      return;
    }

    final content = context.definingUnit.content;
    final lineInfo = LineInfo.fromContent(content);

    final visitor = _Visitor(this, fileName, content, lineInfo);
    registry.addCompilationUnit(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final MultiAnalysisRule rule;
  final String fileName;
  final String content;
  final LineInfo lineInfo;

  _Visitor(this.rule, this.fileName, this.content, this.lineInfo);

  @override
  void visitCompilationUnit(CompilationUnit node) {
    // Check if file ends with _provider
    if (!fileName.endsWith('_provider')) {
      // Report on the first public class
      for (final declaration in node.declarations) {
        if (declaration is ClassDeclaration &&
            !declaration.name.lexeme.startsWith('_')) {
          if (IgnoreUtils.shouldIgnoreAtOffset(
            offset: declaration.name.offset,
            lintName: 'provider_file_naming',
            content: content,
            lineInfo: lineInfo,
          )) {
            break;
          }
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

    // Extract the prefix (e.g., "auth" from "auth_provider")
    final prefix = fileName.replaceAll('_provider', '');
    final expectedNotifierPrefix = PathUtils.snakeToPascal(prefix);

    // Collect all Notifier classes and find first public class
    final notifierClasses = <String>[];
    ClassDeclaration? firstPublicClass;

    for (final declaration in node.declarations) {
      if (declaration is ClassDeclaration) {
        final className = declaration.name.lexeme;
        if (className.startsWith('_')) continue;

        firstPublicClass ??= declaration;

        // Check if it's a Notifier class
        final extendsClause = declaration.extendsClause;
        if (extendsClause != null) {
          final superclassName = extendsClause.superclass.name.lexeme;
          if (superclassName.contains('Notifier')) {
            notifierClasses.add(className);
          }
        }
      }
    }

    // Check if any Notifier class starts with the expected prefix
    if (notifierClasses.isNotEmpty) {
      final hasMatchingNotifier = notifierClasses.any((name) =>
          name.startsWith(expectedNotifierPrefix) && name.endsWith('Notifier'));

      if (!hasMatchingNotifier && firstPublicClass != null) {
        if (IgnoreUtils.shouldIgnoreAtOffset(
          offset: firstPublicClass.name.offset,
          lintName: 'provider_file_naming',
          content: content,
          lineInfo: lineInfo,
        )) {
          return;
        }
        rule.reportAtOffset(
          firstPublicClass.name.offset,
          firstPublicClass.name.length,
          diagnosticCode: ProviderFileNaming.notifierMissingCode,
        );
      }
    }
  }
}
