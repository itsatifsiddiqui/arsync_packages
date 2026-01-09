import 'package:analyzer/source/line_info.dart';

import '../arsync_lint_rule.dart';

/// Rule A3: model_purity
///
/// Models are pure data structures. They cannot contain business logic or UI code.
/// Must be annotated with @freezed and have a fromJson factory.
class ModelPurity extends MultiAnalysisRule {
  ModelPurity()
      : super(
          name: 'model_purity',
          description:
              'Models must be pure data structures without logic dependencies.',
        );

  static const importCode = LintCode(
    'model_purity',
    'Models must be pure data structures without logic dependencies.',
    correctionMessage: 'Remove logic or move it to a ViewModel.',
  );

  static const freezedCode = LintCode(
    'model_purity',
    'Models must be annotated with @freezed.',
    correctionMessage: 'Add the @freezed annotation to the class.',
  );

  static const fromJsonCode = LintCode(
    'model_purity',
    'Models must have a fromJson factory constructor.',
    correctionMessage: 'Add a factory ClassName.fromJson constructor.',
  );

  @override
  List<DiagnosticCode> get diagnosticCodes =>
      [importCode, freezedCode, fromJsonCode];

  static const _bannedPatterns = [
    'providers/',
    'screens/',
    'package:flutter_riverpod',
    'package:riverpod',
    'package:hooks_riverpod',
  ];

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    final path = context.definingUnit.file.path;
    if (!PathUtils.isInModels(path)) {
      return;
    }

    final content = context.definingUnit.content;
    final lineInfo = LineInfo.fromContent(content);

    var visitor = _Visitor(this, content, lineInfo);
    registry.addImportDirective(this, visitor);
    registry.addClassDeclaration(this, visitor);
  }

  static bool isBannedImport(String importUri) {
    for (final pattern in _bannedPatterns) {
      if (importUri.contains(pattern)) {
        return true;
      }
    }
    return false;
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  final MultiAnalysisRule rule;
  final String content;
  final LineInfo lineInfo;

  _Visitor(this.rule, this.content, this.lineInfo);

  @override
  void visitImportDirective(ImportDirective node) {
    final importUri = node.uri.stringValue;
    if (importUri == null) return;

    if (ModelPurity.isBannedImport(importUri)) {
      if (IgnoreUtils.shouldIgnoreAtOffset(
        offset: node.offset,
        lintName: 'model_purity',
        content: content,
        lineInfo: lineInfo,
      )) {
        return;
      }
      rule.reportAtNode(node, diagnosticCode: ModelPurity.importCode);
    }
  }

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    final hasFreezed = node.metadata.any((annotation) {
      final name = annotation.name.name;
      return name == 'freezed' || name == 'Freezed';
    });

    if (!hasFreezed) {
      if (!IgnoreUtils.shouldIgnoreAtOffset(
        offset: node.name.offset,
        lintName: 'model_purity',
        content: content,
        lineInfo: lineInfo,
      )) {
        rule.reportAtOffset(
          node.name.offset,
          node.name.length,
          diagnosticCode: ModelPurity.freezedCode,
        );
      }
    }

    final hasFromJson = node.members.any((member) {
      if (member is ConstructorDeclaration) {
        return member.factoryKeyword != null &&
            member.name?.lexeme == 'fromJson';
      }
      return false;
    });

    if (!hasFromJson) {
      if (!IgnoreUtils.shouldIgnoreAtOffset(
        offset: node.name.offset,
        lintName: 'model_purity',
        content: content,
        lineInfo: lineInfo,
      )) {
        rule.reportAtOffset(
          node.name.offset,
          node.name.length,
          diagnosticCode: ModelPurity.fromJsonCode,
        );
      }
    }
  }
}
