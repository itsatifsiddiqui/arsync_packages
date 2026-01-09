import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';

import '../utils.dart';

/// Quick fix for `provider_file_naming` rule.
///
/// Renames the class to match the expected naming convention.
class ProviderFileNamingFix extends ResolvedCorrectionProducer {
  ProviderFileNamingFix({required super.context});

  static const _fixKind = FixKind(
    'arsync.fix.providerFileNaming',
    100,
    'Rename class to match file name',
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

    // Get the expected class name from the file path
    final path = unitResult.path;
    final fileName = PathUtils.getFileName(path);

    // Extract the prefix from file name (e.g., "auth" from "auth_provider")
    final prefix = fileName.replaceAll('_provider', '');
    final expectedClassName = '${PathUtils.snakeToPascal(prefix)}Notifier';

    await builder.addDartFileEdit(file, (builder) {
      builder.addSimpleReplacement(
        SourceRange(classNameToken.offset, classNameToken.length),
        expectedClassName,
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
