import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';

/// Quick fix for `hook_safety_enforcement` — replace controller instantiation
/// with the corresponding `useX` hook.
class HookSafetyControllerFix extends ResolvedCorrectionProducer {
  HookSafetyControllerFix({required super.context});

  static const _fixKind = FixKind(
    'arsync.fix.hookSafetyController',
    100,
    'Replace with hook',
  );

  static const _controllerToHook = {
    'TextEditingController': 'useTextEditingController',
    'AnimationController': 'useAnimationController',
    'ScrollController': 'useScrollController',
    'PageController': 'usePageController',
    'TabController': 'useTabController',
    'FocusNode': 'useFocusNode',
  };

  @override
  FixKind? get fixKind => _fixKind;

  @override
  CorrectionApplicability get applicability =>
      CorrectionApplicability.singleLocation;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final creation = node.thisOrAncestorOfType<InstanceCreationExpression>();
    if (creation == null) return;

    final hook =
        _controllerToHook[creation.constructorName.type.name.lexeme];
    if (hook == null) return;

    final args = creation.argumentList.arguments
        .map((e) => e.toSource())
        .join(', ');

    await builder.addDartFileEdit(file, (b) {
      b.addSimpleReplacement(
        SourceRange(creation.offset, creation.length),
        '$hook($args)',
      );
    });
  }
}

/// Quick fix for `hook_safety_enforcement` — replace `GlobalKey<FormState>()`
/// with `GlobalObjectKey<FormState>(context)`.
class HookSafetyFormKeyFix extends ResolvedCorrectionProducer {
  HookSafetyFormKeyFix({required super.context});

  static const _fixKind = FixKind(
    'arsync.fix.hookSafetyFormKey',
    100,
    'Replace with GlobalObjectKey<FormState>(context)',
  );

  @override
  FixKind? get fixKind => _fixKind;

  @override
  CorrectionApplicability get applicability =>
      CorrectionApplicability.singleLocation;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final creation = node.thisOrAncestorOfType<InstanceCreationExpression>();
    if (creation == null ||
        creation.constructorName.type.name.lexeme != 'GlobalKey') {
      return;
    }

    await builder.addDartFileEdit(file, (b) {
      b.addSimpleReplacement(
        SourceRange(creation.offset, creation.length),
        'GlobalObjectKey<FormState>(context)',
      );
    });
  }
}
