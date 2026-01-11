import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';

/// Quick fix for `hook_safety_enforcement` rule - controller replacement.
///
/// Replaces direct controller instantiation with hook:
/// - Before: `TextEditingController()`
/// - After: `useTextEditingController()`
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
    final creation = _findInstanceCreation(node);
    if (creation == null) return;

    final typeName = creation.constructorName.type.name.lexeme;
    final hookName = _controllerToHook[typeName];
    if (hookName == null) return;

    // Build the hook call - preserve arguments if any
    final args = creation.argumentList.arguments;
    final argsSource = args.isNotEmpty
        ? '(${args.map((e) => e.toSource()).join(', ')})'
        : '()';
    final replacement = '$hookName$argsSource';

    await builder.addDartFileEdit(file, (builder) {
      builder.addSimpleReplacement(
        SourceRange(creation.offset, creation.length),
        replacement,
      );
    });
  }

  InstanceCreationExpression? _findInstanceCreation(AstNode? node) {
    if (node == null) return null;
    if (node is InstanceCreationExpression) return node;

    AstNode? current = node;
    while (current != null) {
      if (current is InstanceCreationExpression) {
        return current;
      }
      current = current.parent;
    }
    return null;
  }
}

/// Quick fix for `hook_safety_enforcement` rule - FormState key replacement.
///
/// Replaces `GlobalKey<FormState>` with `GlobalObjectKey`:
/// - Before: `GlobalKey<FormState>()`
/// - After: `GlobalObjectKey<FormState>(context)`
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
    final creation = _findInstanceCreation(node);
    if (creation == null) return;

    final typeName = creation.constructorName.type.name.lexeme;
    if (typeName != 'GlobalKey') return;

    final replacement = 'GlobalObjectKey<FormState>(context)';

    await builder.addDartFileEdit(file, (builder) {
      builder.addSimpleReplacement(
        SourceRange(creation.offset, creation.length),
        replacement,
      );
    });
  }

  InstanceCreationExpression? _findInstanceCreation(AstNode? node) {
    if (node == null) return null;
    if (node is InstanceCreationExpression) return node;

    AstNode? current = node;
    while (current != null) {
      if (current is InstanceCreationExpression) {
        return current;
      }
      current = current.parent;
    }
    return null;
  }
}
