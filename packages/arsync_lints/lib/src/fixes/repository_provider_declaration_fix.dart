import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import "../ast_extensions.dart";
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';

import '../utils.dart';

String _filePrefix(String path) =>
    PathUtils.getFileName(path).replaceAll('_repository', '');

/// Quick fix for `repository_provider_declaration` — rename provider to
/// `XRepoProvider`.
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
    final name = node.thisOrAncestorOfType<VariableDeclaration>()?.name;
    if (name == null || name.lexeme.endsWith('RepoProvider')) return;

    final newName =
        '${PathUtils.snakeToCamel(_filePrefix(unitResult.path))}RepoProvider';

    await builder.addDartFileEdit(file, (b) {
      b.addSimpleReplacement(SourceRange(name.offset, name.length), newName);
    });
  }
}

/// Quick fix for `repository_provider_declaration` — insert a provider
/// declaration before the `XRepository` class.
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
    final prefix = _filePrefix(unitResult.path);
    final providerName = '${PathUtils.snakeToCamel(prefix)}RepoProvider';
    final className = '${PathUtils.snakeToPascal(prefix)}Repository';

    final repoClass = unitResult.unit.declarations
        .whereType<ClassDeclaration>()
        .where((c) => c.className.lexeme.endsWith('Repository'))
        .firstOrNull;
    if (repoClass == null) return;

    await builder.addDartFileEdit(file, (b) {
      b.addSimpleInsertion(
        repoClass.offset,
        'final $providerName = Provider((ref) => $className());\n\n',
      );
    });
  }
}
