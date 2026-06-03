import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';

import '../ast_extensions.dart';

/// Quick fix when `Padding` wraps `Container` — move padding to `Container.margin`.
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
    final padding = node.ancestorWidget('Padding');
    if (padding == null) return;

    final paddingArg = padding.namedArg('padding');
    final childArg = padding.namedArg('child');
    if (paddingArg == null || childArg == null) return;

    final container = childArg.expression;
    if (container is! InstanceCreationExpression) return;

    final newContainer = _addMargin(
      container.toSource(),
      paddingArg.expression.toSource(),
    );

    await builder.addDartFileEdit(file, (b) {
      b.addSimpleReplacement(
        SourceRange(padding.offset, padding.length),
        newContainer,
      );
    });
  }

  static String _addMargin(String containerSource, String marginValue) {
    final open = containerSource.indexOf('(');
    if (open == -1) return containerSource;
    final after = containerSource.substring(open + 1);
    if (after.trimLeft().startsWith(')')) {
      return '${containerSource.substring(0, open + 1)}margin: $marginValue)';
    }
    return '${containerSource.substring(0, open + 1)}margin: $marginValue, $after';
  }
}

/// Quick fix when `Container` wraps `Padding` — move padding to `Container.padding`.
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
    final container = node.ancestorWidget('Container');
    if (container == null) return;

    final childArg = container.namedArg('child');
    if (childArg == null) return;

    final padding = childArg.expression;
    if (padding is! InstanceCreationExpression) return;

    final paddingArg = padding.namedArg('padding');
    if (paddingArg == null) return;

    final innerChild = padding.namedArg('child')?.expression.toSource();
    final paddingValue = paddingArg.expression.toSource();

    final newContainer = _rebuild(
      container.toSource(),
      paddingValue,
      innerChild,
    );

    await builder.addDartFileEdit(file, (b) {
      b.addSimpleReplacement(
        SourceRange(container.offset, container.length),
        newContainer,
      );
    });
  }

  static final _childPaddingRe = RegExp(r'child:\s*Padding\s*\([^)]*\)');
  static final _doubleCommaRe = RegExp(r',\s*,');
  static final _leadingCommaRe = RegExp(r'^\s*,\s*');
  static final _trailingCommaRe = RegExp(r'\s*,\s*$');

  static String _rebuild(
    String containerSource,
    String paddingValue,
    String? innerChild,
  ) {
    final open = containerSource.indexOf('(');
    final close = containerSource.lastIndexOf(')');
    if (open == -1 || close <= open) return containerSource;

    final args = <String>['padding: $paddingValue'];
    final existing = containerSource.substring(open + 1, close).trim();
    if (existing.isNotEmpty) {
      final cleaned = existing
          .replaceAll(_childPaddingRe, '')
          .replaceAll(_doubleCommaRe, ',')
          .replaceAll(_leadingCommaRe, '')
          .replaceAll(_trailingCommaRe, '');
      if (cleaned.isNotEmpty) args.add(cleaned);
    }
    if (innerChild != null) args.add('child: $innerChild');

    return 'Container(${args.join(', ')})';
  }
}
