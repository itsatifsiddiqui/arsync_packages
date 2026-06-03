import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';

/// Quick fix for `avoid_hardcoded_color` — replace hardcoded color with
/// `Theme.of(context).colorScheme.primary` placeholder.
class AvoidHardcodedColorFix extends ResolvedCorrectionProducer {
  AvoidHardcodedColorFix({required super.context});

  static const _fixKind = FixKind(
    'arsync.fix.avoidHardcodedColor',
    100,
    'Replace with Theme color',
  );

  @override
  FixKind? get fixKind => _fixKind;

  @override
  CorrectionApplicability get applicability =>
      CorrectionApplicability.singleLocation;

  static const _colorTypes = {'Color', 'MaterialColor', 'MaterialAccentColor'};
  static const _colorMethods = {'fromARGB', 'fromRGBO', 'alphaBlend', 'lerp'};

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final target = node.thisOrAncestorMatching((n) {
      if (n is InstanceCreationExpression) {
        return _colorTypes.contains(n.staticType?.getDisplayString());
      }
      if (n is MethodInvocation) {
        return _colorMethods.contains(n.methodName.name);
      }
      if (n is PrefixedIdentifier) return n.prefix.name == 'Colors';
      return false;
    });
    if (target == null) return;

    await builder.addDartFileEdit(file, (b) {
      b.addSimpleReplacement(
        SourceRange(target.offset, target.length),
        'Theme.of(context).colorScheme.primary',
      );
    });
  }
}
