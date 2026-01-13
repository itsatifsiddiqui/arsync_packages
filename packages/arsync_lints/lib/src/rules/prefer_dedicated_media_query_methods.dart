import '../arsync_lint_rule.dart';

/// A lint rule that encourages the use of dedicated `MediaQuery` methods
/// instead of the generic `MediaQuery.of` or `MediaQuery.maybeOf`.
///
/// Using specialized methods like `MediaQuery.sizeOf` or `MediaQuery.viewInsetsOf`
/// improves performance by reducing unnecessary widget rebuilds.
///
/// ### Example
///
/// #### BAD:
/// ```dart
/// var size = MediaQuery.of(context).size; // LINT
/// var padding = MediaQuery.maybeOf(context)?.padding; // LINT
/// var width = MediaQuery.sizeOf(context).width; // LINT - use widthOf
/// ```
///
/// #### GOOD:
/// ```dart
/// var size = MediaQuery.sizeOf(context);
/// var padding = MediaQuery.viewInsetsOf(context);
/// var width = MediaQuery.widthOf(context);
/// ```
class PreferDedicatedMediaQueryMethods extends AnalysisRule {
  PreferDedicatedMediaQueryMethods()
    : super(name: code.name, description: code.problemMessage);

  static const code = LintCode(
    'prefer_dedicated_media_query_methods',
    'Prefer using dedicated MediaQuery methods.',
    correctionMessage:
        'Consider using MediaQuery.sizeOf, widthOf, heightOf, etc. '
        'instead of accessing properties on generic methods.',
  );

  @override
  DiagnosticCode get diagnosticCode => code;

  @override
  void registerNodeProcessors(
    RuleVisitorRegistry registry,
    RuleContext context,
  ) {
    // NOTE: We pass context.allUnits to the visitor because definingUnit.content
    // only returns the LIBRARY file content, not part file (.g.dart) content.
    // The visitor must use allUnits to get the correct file's content.

    final visitor = _Visitor(this, context.allUnits);
    registry.addMethodInvocation(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  _Visitor(this.rule, this.allUnits);

  final AnalysisRule rule;
  final List<dynamic> allUnits;

  @override
  void visitMethodInvocation(MethodInvocation node) {
    // Skip generated files and nodes with ignore comments
    if (NodeContentHelper.shouldSkipNode(node, allUnits, rule.name)) return;

    final method = node.methodName.name;
    final target = node.target?.toString();

    // Ignore if target is not MediaQuery
    if (target != 'MediaQuery') {
      return;
    }

    // Check for MediaQuery.of / maybeOf
    if (method == 'of' || method == 'maybeOf') {
      rule.reportAtNode(node);
      return;
    }

    // Check for MediaQuery.sizeOf(context).width / height
    if (method == 'sizeOf') {
      // Check if the parent node is a property access (.width or .height)
      final parent = node.parent;
      if (parent is PropertyAccess) {
        final propertyName = parent.propertyName.name;
        if (propertyName == 'width' || propertyName == 'height') {
          // Report on the entire expression including .width or .height
          rule.reportAtNode(parent);
        }
      }
    }
  }
}
