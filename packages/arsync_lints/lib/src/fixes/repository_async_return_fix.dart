import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';

/// Quick fix for `repository_async_return` — wrap return type with `Future<>`.
class RepositoryAsyncReturnFix extends ResolvedCorrectionProducer {
  RepositoryAsyncReturnFix({required super.context});

  static const _fixKind = FixKind(
    'arsync.fix.repositoryAsyncReturn',
    100,
    'Wrap return type with Future<>',
  );

  @override
  FixKind? get fixKind => _fixKind;

  @override
  CorrectionApplicability get applicability =>
      CorrectionApplicability.singleLocation;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final returnType =
        node.thisOrAncestorOfType<TypeAnnotation>() ??
        node.thisOrAncestorOfType<MethodDeclaration>()?.returnType;
    if (returnType == null) return;

    final src = returnType.toSource();
    if (src.startsWith('Future<') || src.startsWith('Stream<')) return;

    await builder.addDartFileEdit(file, (b) {
      b.addSimpleReplacement(
        SourceRange(returnType.offset, returnType.length),
        'Future<$src>',
      );
    });
  }
}
