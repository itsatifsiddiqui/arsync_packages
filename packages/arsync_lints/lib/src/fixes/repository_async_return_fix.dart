import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';

/// Quick fix for `repository_async_return` rule.
///
/// Wraps the return type with Future<>.
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
    final returnType = _findReturnType(node);
    if (returnType == null) return;

    final currentType = returnType.toSource();

    // Don't wrap if already Future or Stream
    if (currentType.startsWith('Future<') || currentType.startsWith('Stream<')) {
      return;
    }

    final newType = 'Future<$currentType>';

    await builder.addDartFileEdit(file, (builder) {
      builder.addSimpleReplacement(
        SourceRange(returnType.offset, returnType.length),
        newType,
      );
    });
  }

  TypeAnnotation? _findReturnType(AstNode? node) {
    if (node == null) return null;
    if (node is TypeAnnotation) return node;

    // Check if we're in a method declaration
    if (node is MethodDeclaration) {
      return node.returnType;
    }

    AstNode? current = node;
    while (current != null) {
      if (current is TypeAnnotation) return current;
      if (current is MethodDeclaration) return current.returnType;
      current = current.parent;
    }
    return null;
  }
}
