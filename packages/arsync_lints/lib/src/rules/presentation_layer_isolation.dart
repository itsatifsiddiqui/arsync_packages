import '../arsync_lint_rule.dart';

/// Rule A1: presentation_layer_isolation
///
/// Files in lib/screens/ and lib/widgets/ cannot import Infrastructure,
/// Repositories, or Data Sources.
/// Also enforces: use Dart records instead of plain parameter classes.
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

  static const _allowedBaseClasses = {
    'StatelessWidget',
    'StatefulWidget',
    'HookWidget',
    'HookConsumerWidget',
    'ConsumerWidget',
    'ConsumerStatefulWidget',
    'State',
  };

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    final path = context.definingUnit.file.path;
    if (!PathUtils.isInScreens(path) && !PathUtils.isInWidgets(path)) return;

    var visitor = _Visitor(this);
    registry.addImportDirective(this, visitor);
    registry.addClassDeclaration(this, visitor);
  }

  static bool isBannedImport(String importUri) {
    for (final pattern in _bannedPatterns) {
      if (importUri.contains(pattern)) return true;
    }
    return false;
  }

  static bool isWidgetClass(ClassDeclaration node) {
    final extendsClause = node.extendsClause;
    if (extendsClause == null) return false;
    return _allowedBaseClasses.contains(extendsClause.superclass.name.lexeme);
  }

  static bool isParameterClass(ClassDeclaration node) {
    bool hasOnlyFinalFields = true;
    bool hasConstructor = false;
    bool hasMethods = false;

    for (final member in node.members) {
      if (member is FieldDeclaration) {
        if (!member.fields.isFinal) hasOnlyFinalFields = false;
      } else if (member is ConstructorDeclaration) {
        hasConstructor = true;
      } else if (member is MethodDeclaration) {
        hasMethods = true;
      }
    }
    return hasConstructor && hasOnlyFinalFields && !hasMethods;
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final MultiAnalysisRule rule;

  _Visitor(this.rule);

  @override
  void visitImportDirective(ImportDirective node) {
    final importUri = node.uri.stringValue;
    if (importUri == null) return;

    if (PresentationLayerIsolation.isBannedImport(importUri)) {
      rule.reportAtNode(node, diagnosticCode: PresentationLayerIsolation.importCode);
    }
  }

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    final className = node.name.lexeme;
    if (className.startsWith('_')) return;
    if (PresentationLayerIsolation.isWidgetClass(node)) return;

    if (PresentationLayerIsolation.isParameterClass(node)) {
      rule.reportAtOffset(
        node.name.offset,
        node.name.length,
        diagnosticCode: PresentationLayerIsolation.useRecordCode,
      );
    }
  }
}
