import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';

/// Quick fix for `provider_class_restriction` rule - make class private.
///
/// If the class is a helper/internal class, this fix makes it private.
class ProviderClassRestrictionMakePrivateFix extends ResolvedCorrectionProducer {
  ProviderClassRestrictionMakePrivateFix({required super.context});

  static const _fixKind = FixKind(
    'arsync.fix.providerClassRestrictionMakePrivate',
    100,
    'Make class private with _ prefix',
  );

  @override
  FixKind? get fixKind => _fixKind;

  @override
  CorrectionApplicability get applicability =>
      CorrectionApplicability.singleLocation;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final classNameToken = _findClassNameToken(node);
    if (classNameToken == null) return;

    final currentName = classNameToken.lexeme;
    if (currentName.startsWith('_')) return;

    final newName = '_$currentName';

    await builder.addDartFileEdit(file, (builder) {
      builder.addSimpleReplacement(
        SourceRange(classNameToken.offset, classNameToken.length),
        newName,
      );
    });
  }

  Token? _findClassNameToken(AstNode? node) {
    if (node == null) return null;

    if (node is ClassDeclaration) {
      return node.name;
    }

    if (node is SimpleIdentifier) {
      final parent = node.parent;
      if (parent is ClassDeclaration) {
        return parent.name;
      }
    }

    AstNode? current = node;
    while (current != null) {
      if (current is ClassDeclaration) {
        return current.name;
      }
      current = current.parent;
    }
    return null;
  }
}
