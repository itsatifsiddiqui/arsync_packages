import '../arsync_lint_rule.dart';

/// Rule A1: `lib/screens/` and `lib/widgets/` cannot import repositories or
/// data-source SDKs. Also enforces using records over plain parameter classes.
class PresentationLayerIsolation extends MultiAnalysisRule {
  PresentationLayerIsolation()
    : super(
        name: 'presentation_layer_isolation',
        description:
            'Presentation layer cannot import repositories or data sources.',
      );

  static const importCode = LintCode(
    'presentation_layer_isolation',
    'Presentation Layer cannot touch Repositories or Data Sources directly. '
        'Use a ViewModel.',
    correctionMessage:
        'Move logic to a ViewModel (Provider) and watch the provider instead.',
  );

  static const useRecordCode = LintCode(
    'presentation_layer_isolation',
    'Use Dart records instead of plain parameter classes in presentation layer.',
    correctionMessage:
        'Replace with a record type: typedef ParamsName = ({Type field1, Type field2});',
  );

  @override
  List<DiagnosticCode> get diagnosticCodes => [importCode, useRecordCode];

  static const _bannedPatterns = [
    'repositories/',
    'package:cloud_firestore',
    'package:http/',
    'package:http',
    'package:dio/',
    'package:dio',
  ];

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    final path = context.definingUnit.file.path;
    if (!PathUtils.isInScreens(path) && !PathUtils.isInWidgets(path)) return;

    registry
      ..addImportDirective(
        this,
        BannedImportVisitor(
          this,
          _bannedPatterns,
          (n) => reportAtNode(n, diagnosticCode: importCode),
        ),
      )
      ..addClassDeclaration(this, _Visitor(this));
  }

  static bool isBannedImport(String importUri) =>
      _bannedPatterns.any(importUri.contains);

  static bool isParameterClass(ClassDeclaration node) {
    var hasConstructor = false;
    for (final member in node.classMembers) {
      if (member is FieldDeclaration && !member.fields.isFinal) return false;
      if (member is MethodDeclaration) return false;
      if (member is ConstructorDeclaration) hasConstructor = true;
    }
    return hasConstructor;
  }
}

class _Visitor extends ArsyncRuleVisitor<MultiAnalysisRule> {
  _Visitor(super.rule);

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    if (node.className.lexeme.startsWith('_')) return;
    if (node.extendsWidgetBase) return;
    if (PresentationLayerIsolation.isParameterClass(node)) {
      rule.reportAtOffset(
        node.className.offset,
        node.className.length,
        diagnosticCode: PresentationLayerIsolation.useRecordCode,
      );
    }
  }
}
