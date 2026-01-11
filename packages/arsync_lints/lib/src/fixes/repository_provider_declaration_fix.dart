import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';

import '../utils.dart';

/// Quick fix for `repository_provider_declaration` rule - rename provider to end with RepoProvider.
class RepositoryProviderDeclarationRenameFix
    extends ResolvedCorrectionProducer {
  RepositoryProviderDeclarationRenameFix({required super.context});

  static const _fixKind = FixKind(
    'arsync.fix.repositoryProviderDeclarationRename',
    100,
    'Rename provider to end with "RepoProvider"',
  );

  @override
  FixKind? get fixKind => _fixKind;

  @override
  CorrectionApplicability get applicability =>
      CorrectionApplicability.singleLocation;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final variableToken = _findVariableToken(node);
    if (variableToken == null) return;

    final currentName = variableToken.lexeme;

    // Already ends with RepoProvider
    if (currentName.endsWith('RepoProvider')) return;

    // Get the file name to extract prefix
    final path = unitResult.path;
    final fileName = PathUtils.getFileName(path);

    // Extract prefix from file name (e.g., auth_repository -> auth)
    final prefix = fileName.replaceAll('_repository', '');
    final newName = '${_snakeToCamel(prefix)}RepoProvider';

    await builder.addDartFileEdit(file, (builder) {
      builder.addSimpleReplacement(
        SourceRange(variableToken.offset, variableToken.length),
        newName,
      );
    });
  }

  /// Convert snake_case to camelCase
  String _snakeToCamel(String snake) {
    final parts = snake.split('_');
    if (parts.isEmpty) return snake;

    final buffer = StringBuffer(parts.first);
    for (var i = 1; i < parts.length; i++) {
      if (parts[i].isNotEmpty) {
        buffer.write(parts[i][0].toUpperCase());
        buffer.write(parts[i].substring(1));
      }
    }
    return buffer.toString();
  }

  Token? _findVariableToken(AstNode? node) {
    if (node == null) return null;

    if (node is VariableDeclaration) {
      return node.name;
    }

    if (node is SimpleIdentifier) {
      final parent = node.parent;
      if (parent is VariableDeclaration) {
        return parent.name;
      }
    }

    AstNode? current = node;
    while (current != null) {
      if (current is VariableDeclaration) {
        return current.name;
      }
      current = current.parent;
    }
    return null;
  }
}

/// Quick fix for `repository_provider_declaration` rule - add provider declaration.
class RepositoryProviderDeclarationAddFix extends ResolvedCorrectionProducer {
  RepositoryProviderDeclarationAddFix({required super.context});

  static const _fixKind = FixKind(
    'arsync.fix.repositoryProviderDeclarationAdd',
    100,
    'Add repository provider declaration',
  );

  @override
  FixKind? get fixKind => _fixKind;

  @override
  CorrectionApplicability get applicability =>
      CorrectionApplicability.singleLocation;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    // Get the file name to extract prefix
    final path = unitResult.path;
    final fileName = PathUtils.getFileName(path);

    // Extract prefix from file name (e.g., auth_repository -> auth)
    final prefix = fileName.replaceAll('_repository', '');
    final providerName = '${_snakeToCamel(prefix)}RepoProvider';
    final className = '${_snakeToPascal(prefix)}Repository';

    // Find the first class declaration to insert before it
    final unit = unitResult.unit;
    ClassDeclaration? repoClass;

    for (final decl in unit.declarations) {
      if (decl is ClassDeclaration && decl.name.lexeme.endsWith('Repository')) {
        repoClass = decl;
        break;
      }
    }

    if (repoClass == null) return;

    final providerDeclaration =
        'final $providerName = Provider((ref) => $className());\n\n';

    await builder.addDartFileEdit(file, (builder) {
      builder.addSimpleInsertion(repoClass!.offset, providerDeclaration);
    });
  }

  /// Convert snake_case to camelCase
  String _snakeToCamel(String snake) {
    final parts = snake.split('_');
    if (parts.isEmpty) return snake;

    final buffer = StringBuffer(parts.first);
    for (var i = 1; i < parts.length; i++) {
      if (parts[i].isNotEmpty) {
        buffer.write(parts[i][0].toUpperCase());
        buffer.write(parts[i].substring(1));
      }
    }
    return buffer.toString();
  }

  /// Convert snake_case to PascalCase
  String _snakeToPascal(String snake) {
    final parts = snake.split('_');
    if (parts.isEmpty) return snake;

    final buffer = StringBuffer();
    for (final part in parts) {
      if (part.isNotEmpty) {
        buffer.write(part[0].toUpperCase());
        buffer.write(part.substring(1));
      }
    }
    return buffer.toString();
  }
}
