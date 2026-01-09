import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';

/// Quick fix for `no_context_in_providers` rule.
///
/// Removes the BuildContext parameter from the function/method/constructor.
class NoContextInProvidersFix extends ResolvedCorrectionProducer {
  NoContextInProvidersFix({required super.context});

  static const _fixKind = FixKind(
    'arsync.fix.noContextInProviders',
    100,
    'Remove BuildContext parameter',
  );

  @override
  FixKind? get fixKind => _fixKind;

  @override
  CorrectionApplicability get applicability =>
      CorrectionApplicability.singleLocation;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final parameter = _findParameter(node);
    if (parameter == null) return;

    // Find the parameter list
    final parameterList = parameter.parent;
    if (parameterList is! FormalParameterList) return;

    final params = parameterList.parameters;
    final paramIndex = params.indexOf(parameter);
    if (paramIndex == -1) return;

    int deleteStart;
    int deleteEnd;

    if (params.length == 1) {
      // Only parameter, just remove it
      deleteStart = parameter.offset;
      deleteEnd = parameter.end;
    } else if (paramIndex == 0) {
      // First parameter, remove up to the comma after
      deleteStart = parameter.offset;
      deleteEnd = params[1].offset;
    } else {
      // Not first parameter, remove from previous comma
      deleteStart = params[paramIndex - 1].end;
      deleteEnd = parameter.end;
    }

    await builder.addDartFileEdit(file, (builder) {
      builder.addDeletion(SourceRange(deleteStart, deleteEnd - deleteStart));
    });
  }

  FormalParameter? _findParameter(AstNode? node) {
    if (node == null) return null;
    if (node is FormalParameter) return node;

    AstNode? current = node;
    while (current != null) {
      if (current is FormalParameter) return current;
      current = current.parent;
    }
    return null;
  }
}
