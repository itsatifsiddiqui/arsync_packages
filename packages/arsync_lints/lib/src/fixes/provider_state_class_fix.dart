import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';

/// Quick fix for `provider_state_class` rule - add @freezed annotation.
class ProviderStateClassAddFreezedFix extends ResolvedCorrectionProducer {
  ProviderStateClassAddFreezedFix({required super.context});

  static const _fixKind = FixKind(
    'arsync.fix.providerStateClassAddFreezed',
    100,
    'Add @freezed annotation',
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

    // Check if already has @freezed
    final hasFreezed = classDecl.metadata.any((a) =>
        a.name.name == 'freezed' || a.name.name == 'Freezed');
    if (hasFreezed) return;

    await builder.addDartFileEdit(file, (builder) {
      builder.addSimpleInsertion(classDecl.offset, '@freezed\n');
    });
  }

  ClassDeclaration? _findClassDeclaration(AstNode? node) {
    if (node == null) return null;
    if (node is ClassDeclaration) return node;

    if (node is SimpleIdentifier) {
      final parent = node.parent;
      if (parent is ClassDeclaration) return parent;
    }

    AstNode? current = node;
    while (current != null) {
      if (current is ClassDeclaration) return current;
      current = current.parent;
    }
    return null;
  }
}

/// Quick fix for `provider_state_class` rule - move state class to this file.
///
/// This fix adds a TODO comment as a placeholder since actually moving
/// the class requires more complex refactoring.
class ProviderStateClassMoveHereFix extends ResolvedCorrectionProducer {
  ProviderStateClassMoveHereFix({required super.context});

  static const _fixKind = FixKind(
    'arsync.fix.providerStateClassMoveHere',
    90,
    'Add TODO to move state class here',
  );

  @override
  FixKind? get fixKind => _fixKind;

  @override
  CorrectionApplicability get applicability =>
      CorrectionApplicability.singleLocation;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final typeNode = _findNamedType(node);
    if (typeNode == null) return;

    final typeName = typeNode.name.lexeme;

    // Find the compilation unit to insert the TODO at the end
    final unit = typeNode.thisOrAncestorOfType<CompilationUnit>();
    if (unit == null) return;

    final todoComment = '''

// TODO: Move $typeName class here and add @freezed annotation
// @freezed
// class $typeName with _\$$typeName {
//   const factory $typeName() = _$typeName;
// }
''';

    await builder.addDartFileEdit(file, (builder) {
      builder.addSimpleInsertion(unit.end, todoComment);
    });
  }

  NamedType? _findNamedType(AstNode? node) {
    if (node == null) return null;
    if (node is NamedType) return node;

    AstNode? current = node;
    while (current != null) {
      if (current is NamedType) return current;
      current = current.parent;
    }
    return null;
  }
}
