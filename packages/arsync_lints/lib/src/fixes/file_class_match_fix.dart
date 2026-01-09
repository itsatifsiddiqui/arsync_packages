import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';

import '../utils.dart';

/// Quick fix for `file_class_match` rule.
///
/// Renames the class to match the file name:
/// - File: `login_screen.dart`
/// - Before: `class LoginPage {}`
/// - After: `class LoginScreen {}`
class FileClassMatchFix extends ResolvedCorrectionProducer {
  FileClassMatchFix({required super.context});

  static const _fixKind = FixKind(
    'arsync.fix.fileClassMatch',
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
    // Get the expected class name from the file path
    final path = unitResult.path;
    final fileName = PathUtils.getFileName(path);
    final expectedClassName = PathUtils.snakeToPascal(fileName);

    // Find the class declaration
    final classNameToken = _findClassName(node);
    if (classNameToken == null) return;

    await builder.addDartFileEdit(file, (builder) {
      builder.addSimpleReplacement(
        SourceRange(classNameToken.offset, classNameToken.length),
        expectedClassName,
      );
    });
  }

  Token? _findClassName(AstNode? node) {
    if (node == null) return null;

    if (node is ClassDeclaration) {
      return node.name;
    }

    // Check if node is the identifier itself
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
