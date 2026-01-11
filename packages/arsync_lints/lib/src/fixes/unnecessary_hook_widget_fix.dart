import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';

/// Quick fix for `unnecessary_hook_widget` rule.
///
/// Replaces `HookWidget` with `StatelessWidget`.
class UnnecessaryHookWidgetFix extends ResolvedCorrectionProducer {
  UnnecessaryHookWidgetFix({required super.context});

  static const _fixKind = FixKind(
    'arsync.fix.unnecessaryHookWidget',
    100,
    'Replace with StatelessWidget',
  );

  @override
  FixKind? get fixKind => _fixKind;

  @override
  CorrectionApplicability get applicability =>
      CorrectionApplicability.singleLocation;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final classDeclaration = _findClassDeclaration(node);
    if (classDeclaration == null) return;

    final superclass = classDeclaration.extendsClause?.superclass;
    if (superclass == null) return;

    await builder.addDartFileEdit(file, (builder) {
      builder.addSimpleReplacement(
        SourceRange(superclass.offset, superclass.length),
        'StatelessWidget',
      );
    });
  }

  ClassDeclaration? _findClassDeclaration(AstNode? node) {
    if (node == null) return null;

    AstNode? current = node;
    while (current != null) {
      if (current is ClassDeclaration) {
        return current;
      }
      current = current.parent;
    }
    return null;
  }
}
