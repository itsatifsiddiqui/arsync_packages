import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';

/// Quick fix for `avoid_unnecessary_padding_widget` rule when Padding wraps Container.
///
/// Moves the padding value to Container's margin property and removes the Padding wrapper.
class PaddingWrapsContainerFix extends ResolvedCorrectionProducer {
  PaddingWrapsContainerFix({required super.context});

  static const _fixKind = FixKind(
    'arsync.fix.paddingWrapsContainer',
    100,
    'Move padding to Container margin',
  );

  @override
  FixKind? get fixKind => _fixKind;

  @override
  CorrectionApplicability get applicability =>
      CorrectionApplicability.singleLocation;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final paddingWidget = _findPaddingWidget(node);
    if (paddingWidget == null) return;

    // Get the padding argument value
    final paddingArg = _findNamedArgument(paddingWidget, 'padding');
    if (paddingArg == null) return;

    // Get the child Container
    final childArg = _findNamedArgument(paddingWidget, 'child');
    if (childArg == null) return;

    final containerWidget = childArg.expression;
    if (containerWidget is! InstanceCreationExpression) return;

    final paddingValue = paddingArg.expression.toSource();
    final containerSource = containerWidget.toSource();

    // Build new Container with margin
    final newContainer = _addMarginToContainer(containerSource, paddingValue);

    await builder.addDartFileEdit(file, (builder) {
      builder.addSimpleReplacement(
        SourceRange(paddingWidget.offset, paddingWidget.length),
        newContainer,
      );
    });
  }

  String _addMarginToContainer(String containerSource, String marginValue) {
    // Find the position after "Container("
    final openParenIndex = containerSource.indexOf('(');
    if (openParenIndex == -1) return containerSource;

    final beforeArgs = containerSource.substring(0, openParenIndex + 1);
    final afterArgs = containerSource.substring(openParenIndex + 1);

    // Check if there are existing arguments
    final trimmedAfter = afterArgs.trimLeft();
    if (trimmedAfter.startsWith(')')) {
      // Empty Container()
      return '${beforeArgs}margin: $marginValue)';
    } else {
      // Has arguments, add margin as first argument
      return '${beforeArgs}margin: $marginValue, $afterArgs';
    }
  }

  InstanceCreationExpression? _findPaddingWidget(AstNode? node) {
    if (node == null) return null;

    AstNode? current = node;
    while (current != null) {
      if (current is InstanceCreationExpression) {
        final typeName = current.constructorName.type.name.lexeme;
        if (typeName == 'Padding') {
          return current;
        }
      }
      current = current.parent;
    }
    return null;
  }

  NamedExpression? _findNamedArgument(
    InstanceCreationExpression node,
    String argName,
  ) {
    for (final arg in node.argumentList.arguments) {
      if (arg is NamedExpression && arg.name.label.name == argName) {
        return arg;
      }
    }
    return null;
  }
}

/// Quick fix for `avoid_unnecessary_padding_widget` rule when Container wraps Padding.
///
/// Moves the Padding's padding value to Container's padding property and
/// connects Padding's child directly to Container.
class ContainerWrapsPaddingFix extends ResolvedCorrectionProducer {
  ContainerWrapsPaddingFix({required super.context});

  static const _fixKind = FixKind(
    'arsync.fix.containerWrapsPadding',
    100,
    'Move Padding to Container padding property',
  );

  @override
  FixKind? get fixKind => _fixKind;

  @override
  CorrectionApplicability get applicability =>
      CorrectionApplicability.singleLocation;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    final containerWidget = _findContainerWidget(node);
    if (containerWidget == null) return;

    // Get the child argument (should be a Padding)
    final childArg = _findNamedArgument(containerWidget, 'child');
    if (childArg == null) return;

    final paddingWidget = childArg.expression;
    if (paddingWidget is! InstanceCreationExpression) return;

    // Get padding value from Padding widget
    final paddingArg = _findNamedArgument(paddingWidget, 'padding');
    if (paddingArg == null) return;

    // Get Padding's child
    final paddingChildArg = _findNamedArgument(paddingWidget, 'child');

    final paddingValue = paddingArg.expression.toSource();
    final innerChild = paddingChildArg?.expression.toSource();

    // Rebuild the entire Container with the padding property and inner child
    final containerSource = containerWidget.toSource();
    final newContainer = _rebuildContainerWithPadding(
      containerSource,
      paddingValue,
      innerChild,
    );

    await builder.addDartFileEdit(file, (builder) {
      builder.addSimpleReplacement(
        SourceRange(containerWidget.offset, containerWidget.length),
        newContainer,
      );
    });
  }

  String _rebuildContainerWithPadding(
    String containerSource,
    String paddingValue,
    String? innerChild,
  ) {
    // Find the position after "Container("
    final openParenIndex = containerSource.indexOf('(');
    if (openParenIndex == -1) return containerSource;

    // Extract all arguments except child
    final args = <String>[];
    args.add('padding: $paddingValue');

    // Parse existing arguments (simplified approach)
    final argStart = openParenIndex + 1;
    var argEnd = containerSource.lastIndexOf(')');
    if (argEnd <= argStart) return containerSource;

    final argsContent = containerSource.substring(argStart, argEnd).trim();

    // Add existing args except child
    if (argsContent.isNotEmpty) {
      // Remove the child: Padding(...) part and add other args
      final childPattern = RegExp(r'child:\s*Padding\s*\([^)]*\)');
      final cleanedArgs = argsContent.replaceAll(childPattern, '').trim();

      // Clean up any double commas or leading/trailing commas
      var finalArgs = cleanedArgs
          .replaceAll(RegExp(r',\s*,'), ',')
          .replaceAll(RegExp(r'^\s*,\s*'), '')
          .replaceAll(RegExp(r'\s*,\s*$'), '');

      if (finalArgs.isNotEmpty) {
        args.add(finalArgs);
      }
    }

    // Add the inner child if present
    if (innerChild != null) {
      args.add('child: $innerChild');
    }

    return 'Container(${args.join(', ')})';
  }

  InstanceCreationExpression? _findContainerWidget(AstNode? node) {
    if (node == null) return null;

    AstNode? current = node;
    while (current != null) {
      if (current is InstanceCreationExpression) {
        final typeName = current.constructorName.type.name.lexeme;
        if (typeName == 'Container') {
          return current;
        }
      }
      current = current.parent;
    }
    return null;
  }

  NamedExpression? _findNamedArgument(
    InstanceCreationExpression node,
    String argName,
  ) {
    for (final arg in node.argumentList.arguments) {
      if (arg is NamedExpression && arg.name.label.name == argName) {
        return arg;
      }
    }
    return null;
  }
}
