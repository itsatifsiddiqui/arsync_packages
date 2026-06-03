import '../arsync_lint_rule.dart';

/// Rule A2: shared widgets in `lib/widgets/` must be pure (no Riverpod/provider
/// imports) and each file must contain at most one public widget class.
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

  static const _bannedPatterns = [
    'providers/',
    'package:flutter_riverpod',
    'package:riverpod',
    'package:hooks_riverpod',
  ];

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    if (!PathUtils.isInWidgets(context.definingUnit.file.path)) return;

    registry
      ..addImportDirective(
        this,
        BannedImportVisitor(
          this,
          _bannedPatterns,
          (n) => reportAtNode(n, diagnosticCode: importCode),
        ),
      )
      ..addCompilationUnit(this, _Visitor(this));
  }

  static bool isBannedImport(String uri) => _bannedPatterns.any(uri.contains);
}

class _Visitor extends ArsyncRuleVisitor<MultiAnalysisRule> {
  _Visitor(super.rule);

  @override
  void visitCompilationUnit(CompilationUnit node) {

    final publics = [
      for (final d in node.declarations.whereType<ClassDeclaration>())
        if (!d.className.lexeme.startsWith('_') && d.extendsWidgetBase)
          d,
    ];
    for (final extra in publics.skip(1)) {
      rule.reportAtOffset(
        extra.className.offset,
        extra.className.length,
        diagnosticCode: SharedWidgetPurity.singleWidgetCode,
      );
    }
  }
}
