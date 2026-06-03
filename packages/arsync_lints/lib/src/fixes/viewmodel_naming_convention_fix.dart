import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import "../ast_extensions.dart";
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';

/// Quick fix for `viewmodel_naming_convention` — ensure the Notifier class
/// name ends with "Notifier".
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
    final name = node.thisOrAncestorOfType<ClassDeclaration>()?.className;
    if (name == null || name.lexeme.endsWith('Notifier')) return;

    final completion = _completePartial(name.lexeme, 'Notifier');
    final newName = completion ?? '${name.lexeme}Notifier';

    await builder.addDartFileEdit(file, (b) {
      b.addSimpleReplacement(SourceRange(name.offset, name.length), newName);
    });
  }

  /// If [name] ends with a prefix of [suffix] (e.g. "AuthNotif" of "Notifier"),
  /// returns the completed name (e.g. "AuthNotifier"); otherwise `null`.
  static String? _completePartial(String name, String suffix) {
    final max = name.length < suffix.length - 1
        ? name.length
        : suffix.length - 1;
    for (var len = max; len >= 1; len--) {
      if (name.endsWith(suffix.substring(0, len))) {
        return name + suffix.substring(len);
      }
    }
    return null;
  }
}

/// Quick fix for `viewmodel_naming_convention` — append `Provider` suffix.
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
    final name = node.thisOrAncestorOfType<VariableDeclaration>()?.name;
    if (name == null || name.lexeme.endsWith('Provider')) return;

    await builder.addDartFileEdit(file, (b) {
      b.addSimpleReplacement(
        SourceRange(name.offset, name.length),
        '${name.lexeme}Provider',
      );
    });
  }
}
