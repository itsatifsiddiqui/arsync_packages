import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';

/// Quick fix for `print_ban` rule.
///
/// Converts print/debugPrint calls to use .log() extension:
/// - Before: `print('message')`
/// - After: `'message'.log()`
class PrintBanFix extends ResolvedCorrectionProducer {
  PrintBanFix({required super.context});

  static const _fixKind = FixKind(
    'arsync.fix.printBan',
    100,
    "Replace with '.log()' extension",
  );

  @override
  FixKind? get fixKind => _fixKind;

  @override
  CorrectionApplicability get applicability =>
      CorrectionApplicability.singleLocation;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final targetNode = _findPrintInvocation(node);
    if (targetNode == null) return;

    // Get the argument (the message being printed)
    ArgumentList? arguments;
    if (targetNode is MethodInvocation) {
      arguments = targetNode.argumentList;
    } else if (targetNode is FunctionExpressionInvocation) {
      arguments = targetNode.argumentList;
    }

    if (arguments == null || arguments.arguments.isEmpty) return;

    // Get the first argument (the message)
    final firstArg = arguments.arguments.first;
    final messageSource = firstArg.toSource();

    // Build the replacement: 'message'.log()
    final replacement = '$messageSource.log()';

    await builder.addDartFileEdit(file, (builder) {
      builder.addSimpleReplacement(
        SourceRange(targetNode.offset, targetNode.length),
        replacement,
      );
    });
  }

  AstNode? _findPrintInvocation(AstNode? node) {
    if (node == null) return null;

    AstNode? current = node;
    while (current != null) {
      if (current is MethodInvocation) {
        final name = current.methodName.name;
        if (name == 'print' || name == 'debugPrint') {
          return current;
        }
      }
      if (current is FunctionExpressionInvocation) {
        final function = current.function;
        if (function is SimpleIdentifier) {
          if (function.name == 'print' || function.name == 'debugPrint') {
            return current;
          }
        }
      }
      current = current.parent;
    }
    return null;
  }
}
