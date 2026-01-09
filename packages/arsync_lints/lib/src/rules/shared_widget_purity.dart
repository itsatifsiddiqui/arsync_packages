import '../arsync_lint_rule.dart';

/// Rule A2: shared_widget_purity
///
/// Shared Widgets must be dumb and pure. They cannot know about business logic.
/// Each widget file should contain only ONE public widget.
class SharedWidgetPurity extends MultiAnalysisRule {
  SharedWidgetPurity()
      : super(
          name: 'shared_widget_purity',
          description:
              'Shared widgets must be pure and not depend on business logic.',
        );

  static const importCode = LintCode(
    'shared_widget_purity',
    'Shared Widgets must be pure. Pass data as parameters, do not read providers.',
    correctionMessage:
        'Pass data as Constructor Arguments instead of reading providers.',
  );

  static const singleWidgetCode = LintCode(
    'shared_widget_purity',
    'Widget file should only contain ONE public widget. Other widgets must be private (_).',
    correctionMessage:
        'Make this widget private by prefixing with _ or move to a separate file.',
  );

  @override
  List<DiagnosticCode> get diagnosticCodes => [importCode, singleWidgetCode];

  /// Banned import patterns for shared widgets.
  static const _bannedPatterns = [
    'providers/',
    'package:flutter_riverpod',
    'package:riverpod',
    'package:hooks_riverpod',
  ];

  /// Widget base classes
  static const _widgetBaseClasses = {
    'StatelessWidget',
    'StatefulWidget',
    'HookWidget',
    'HookConsumerWidget',
    'ConsumerWidget',
    'ConsumerStatefulWidget',
  };

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    final path = context.definingUnit.file.path;
    if (!PathUtils.isInWidgets(path)) {
      return;
    }

    var visitor = _Visitor(this);
    registry.addImportDirective(this, visitor);
    registry.addCompilationUnit(this, visitor);
  }

  static bool isBannedImport(String importUri) {
    for (final pattern in _bannedPatterns) {
      if (importUri.contains(pattern)) {
        return true;
      }
    }
    return false;
  }

  static bool isWidgetClass(ClassDeclaration node) {
    final extendsClause = node.extendsClause;
    if (extendsClause == null) return false;

    final superclassName = extendsClause.superclass.name.lexeme;
    return _widgetBaseClasses.contains(superclassName);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final MultiAnalysisRule rule;

  _Visitor(this.rule);

  @override
  void visitImportDirective(ImportDirective node) {
    final importUri = node.uri.stringValue;
    if (importUri == null) return;

    if (SharedWidgetPurity.isBannedImport(importUri)) {
      rule.reportAtNode(node, diagnosticCode: SharedWidgetPurity.importCode);
    }
  }

  @override
  void visitCompilationUnit(CompilationUnit node) {
    final publicWidgets = <ClassDeclaration>[];

    for (final declaration in node.declarations) {
      if (declaration is ClassDeclaration) {
        final className = declaration.name.lexeme;
        if (className.startsWith('_')) continue;

        if (SharedWidgetPurity.isWidgetClass(declaration)) {
          publicWidgets.add(declaration);
        }
      }
    }

    if (publicWidgets.length > 1) {
      for (var i = 1; i < publicWidgets.length; i++) {
        rule.reportAtOffset(
          publicWidgets[i].name.offset,
          publicWidgets[i].name.length,
          diagnosticCode: SharedWidgetPurity.singleWidgetCode,
        );
      }
    }
  }
}
