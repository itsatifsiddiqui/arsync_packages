import 'package:analysis_server_plugin/edit/dart/correction_producer.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:analyzer_plugin/utilities/change_builder/change_builder_core.dart';
import 'package:analyzer_plugin/utilities/fixes/fixes.dart';

/// Quick fix for `prefer_dedicated_media_query_methods` rule.
///
/// Replaces MediaQuery.of(context).property with MediaQuery.propertyOf(context).
class PreferDedicatedMediaQueryMethodsFix extends ResolvedCorrectionProducer {
  PreferDedicatedMediaQueryMethodsFix({required super.context});

  static const _fixKind = FixKind(
    'arsync.fix.preferDedicatedMediaQueryMethods',
    100,
    'Use dedicated MediaQuery method',
  );

  @override
  FixKind? get fixKind => _fixKind;

  @override
  CorrectionApplicability get applicability =>
      CorrectionApplicability.singleLocation;

  @override
  Future<void> compute(ChangeBuilder builder) async {
    // Check if it's MediaQuery.sizeOf(context).width/height
    final propertyAccess = _findPropertyAccess(node);
    if (propertyAccess != null) {
      final methodInvocation = propertyAccess.target;
      if (methodInvocation is MethodInvocation &&
          methodInvocation.methodName.name == 'sizeOf') {
        final propertyName = propertyAccess.propertyName.name;
        final contextArg = methodInvocation.argumentList.toSource();

        String replacement;
        if (propertyName == 'width') {
          replacement = 'MediaQuery.widthOf$contextArg';
        } else if (propertyName == 'height') {
          replacement = 'MediaQuery.heightOf$contextArg';
        } else {
          return;
        }

        await builder.addDartFileEdit(file, (builder) {
          builder.addSimpleReplacement(
            SourceRange(propertyAccess.offset, propertyAccess.length),
            replacement,
          );
        });
        return;
      }
    }

    // Check if it's MediaQuery.of(context) or MediaQuery.maybeOf(context)
    final methodInvocation = _findMediaQueryOf(node);
    if (methodInvocation == null) return;

    final contextArg = methodInvocation.argumentList.toSource();

    // Default replacement - suggest sizeOf as a common use case
    await builder.addDartFileEdit(file, (builder) {
      builder.addSimpleReplacement(
        SourceRange(methodInvocation.offset, methodInvocation.length),
        'MediaQuery.sizeOf$contextArg',
      );
    });
  }

  PropertyAccess? _findPropertyAccess(AstNode? node) {
    if (node == null) return null;
    if (node is PropertyAccess) return node;

    AstNode? current = node;
    while (current != null) {
      if (current is PropertyAccess) return current;
      current = current.parent;
    }
    return null;
  }

  MethodInvocation? _findMediaQueryOf(AstNode? node) {
    if (node == null) return null;

    AstNode? current = node;
    while (current != null) {
      if (current is MethodInvocation) {
        final target = current.target?.toString();
        final method = current.methodName.name;
        if (target == 'MediaQuery' && (method == 'of' || method == 'maybeOf')) {
          return current;
        }
      }
      current = current.parent;
    }
    return null;
  }
}
