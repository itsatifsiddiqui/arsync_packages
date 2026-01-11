import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';

/// Quick fix for `prefer_to_include_sliver_in_name` rule.
///
/// Adds "Sliver" prefix to the class name.
class PreferToIncludeSliverInNameFix extends ResolvedCorrectionProducer {
  PreferToIncludeSliverInNameFix({required super.context});

  static const _fixKind = FixKind(
    'arsync.fix.preferToIncludeSliverInName',
    100,
    'Add "Sliver" prefix to class name',
  );

  @override
  FixKind? get fixKind => _fixKind;

  @override
  CorrectionApplicability get applicability =>
      CorrectionApplicability.singleLocation;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final classDecl = _findClassDeclaration(node);
    if (classDecl == null) return;

    final className = classDecl.name.lexeme;
    final newClassName = 'Sliver$className';

    await builder.addDartFileEdit(file, (builder) {
      builder.addSimpleReplacement(
        SourceRange(classDecl.name.offset, classDecl.name.length),
        newClassName,
      );
    });
  }

  ClassDeclaration? _findClassDeclaration(AstNode? node) {
    if (node == null) return null;
    if (node is ClassDeclaration) return node;

    AstNode? current = node;
    while (current != null) {
      if (current is ClassDeclaration) return current;
      current = current.parent;
    }
    return null;
  }
}
