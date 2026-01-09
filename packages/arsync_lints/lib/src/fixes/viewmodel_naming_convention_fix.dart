import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';

/// Quick fix for `viewmodel_naming_convention` rule - class naming.
///
/// Adds "Notifier" suffix to classes extending Notifier:
/// - Before: `class AuthViewModel extends Notifier`
/// - After: `class AuthNotifier extends Notifier`
class ViewModelClassNamingFix extends ResolvedCorrectionProducer {
  ViewModelClassNamingFix({required super.context});

  static const _fixKind = FixKind(
    'arsync.fix.viewModelClassNaming',
    100,
    'Add "Notifier" suffix to class name',
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
    if (currentName.endsWith('Notifier')) return;

    // Remove common suffixes before adding Notifier
    var newName = currentName;
    for (final suffix in ['ViewModel', 'VM', 'Controller', 'State']) {
      if (newName.endsWith(suffix)) {
        newName = newName.substring(0, newName.length - suffix.length);
        break;
      }
    }
    newName = '${newName}Notifier';

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

/// Quick fix for `viewmodel_naming_convention` rule - provider naming.
///
/// Adds "Provider" suffix to provider variables:
/// - Before: `final auth = NotifierProvider.autoDispose(...)`
/// - After: `final authProvider = NotifierProvider.autoDispose(...)`
class ViewModelProviderNamingFix extends ResolvedCorrectionProducer {
  ViewModelProviderNamingFix({required super.context});

  static const _fixKind = FixKind(
    'arsync.fix.viewModelProviderNaming',
    100,
    'Add "Provider" suffix to variable name',
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
    if (currentName.endsWith('Provider')) return;

    final newName = '${currentName}Provider';

    await builder.addDartFileEdit(file, (builder) {
      builder.addSimpleReplacement(
        SourceRange(variableToken.offset, variableToken.length),
        newName,
      );
    });
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
