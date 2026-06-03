import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';

/// Quick fix for `print_ban` — replace `print(x)` / `debugPrint(x)` with `x.log()`.
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

  static bool _isPrintCall(AstNode n) {
    if (n is MethodInvocation) {
      return n.methodName.name == 'print' ||
          n.methodName.name == 'debugPrint';
    }
    if (n is FunctionExpressionInvocation) {
      final f = n.function;
      return f is SimpleIdentifier &&
          (f.name == 'print' || f.name == 'debugPrint');
    }
    return false;
  }

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final target = node.thisOrAncestorMatching(_isPrintCall);
    if (target == null) return;

    final args = target is MethodInvocation
        ? target.argumentList
        : (target as FunctionExpressionInvocation).argumentList;
    if (args.arguments.isEmpty) return;

    await builder.addDartFileEdit(file, (b) {
      b.addSimpleReplacement(
        SourceRange(target.offset, target.length),
        '${args.arguments.first.toSource()}.log()',
      );
    });
  }
}
