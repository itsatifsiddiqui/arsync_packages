import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';

import '../utils.dart';

/// Quick fix for `provider_single_per_file` rule - rename provider to match file.
class ProviderSinglePerFileRenameFix extends ResolvedCorrectionProducer {
  ProviderSinglePerFileRenameFix({required super.context});

  static const _fixKind = FixKind(
    'arsync.fix.providerSinglePerFileRename',
    100,
    'Rename provider to match file name',
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

    // Get the expected provider name from the file path
    final path = unitResult.path;
    final fileName = PathUtils.getFileName(path);

    if (!fileName.endsWith('_provider')) return;

    // Extract the prefix and build expected name
    final prefix = fileName.replaceAll('_provider', '');
    final expectedProviderName = '${_snakeToCamel(prefix)}Provider';

    await builder.addDartFileEdit(file, (builder) {
      builder.addSimpleReplacement(
        SourceRange(variableToken.offset, variableToken.length),
        expectedProviderName,
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
