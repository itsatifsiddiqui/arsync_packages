import '../arsync_lint_rule.dart';

/// A lint rule that warns against using Container when it doesn't use any
/// of Container's specific properties.
///
/// Container is a convenience widget that combines several common painting,
/// positioning, and sizing widgets. However, if you're only using it to wrap
/// a child without any decoration, padding, margin, constraints, or other
/// Container-specific properties, the Container is unnecessary and should
/// be removed.
///
/// Properties that justify keeping a Container:
/// - `color`
/// - `decoration`
/// - `foregroundDecoration`
/// - `width`
/// - `height`
/// - `constraints`
/// - `margin`
/// - `padding`
/// - `alignment`
/// - `transform`
/// - `transformAlignment`
/// - `clipBehavior` (if not Clip.none)
///
/// ### Example
///
/// #### BAD:
/// ```dart
/// Container(
///   child: Text('Hello'), // LINT - Container adds no value
/// )
/// ```
///
/// #### GOOD:
/// ```dart
/// // Just use the child directly
/// Text('Hello')
///
/// // Or use Container with meaningful properties
/// Container(
///   padding: EdgeInsets.all(8),
///   child: Text('Hello'),
/// )
/// ```
class UnnecessaryContainer extends AnalysisRule {
  UnnecessaryContainer()
    : super(name: code.name, description: code.problemMessage);

  static const code = LintCode(
    'unnecessary_container',
    'Unnecessary Container widget.',
    correctionMessage:
        'Remove the Container and use the child directly, or add Container-specific properties.',
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
    final visitor = _Visitor(this, context.allUnits);
    registry.addInstanceCreationExpression(this, visitor);
  }
}

class _Visitor extends SimpleAstVisitor<void> {
  _Visitor(this.rule, this.allUnits);

  final AnalysisRule rule;
  final List<dynamic> allUnits;

  /// Properties that justify keeping a Container.
  /// If any of these are present, the Container is not unnecessary.
  static const _meaningfulProperties = {
    'color',
    'decoration',
    'foregroundDecoration',
    'width',
    'height',
    'constraints',
    'margin',
    'padding',
    'alignment',
    'transform',
    'transformAlignment',
  };

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    // Skip generated files and nodes with ignore comments
    if (NodeContentHelper.shouldSkipNode(node, allUnits, rule.name)) return;

    final className = node.staticType?.getDisplayString();
    if (className != 'Container') return;

    // Check if the Container has a child
    final hasChild = _hasArgument(node, 'child');
    if (!hasChild) {
      // Container without child - also unnecessary but different case
      // For now, we only lint when there's a child being wrapped unnecessarily
      return;
    }

    // Check for meaningful properties
    for (final arg in node.argumentList.arguments) {
      if (arg is NamedExpression) {
        final argName = arg.name.label.name;

        // Check if this is a meaningful property
        if (_meaningfulProperties.contains(argName)) {
          return; // Container is justified
        }

        // Special case: clipBehavior is meaningful only if not Clip.none
        if (argName == 'clipBehavior') {
          final value = arg.expression;
          if (value is PrefixedIdentifier) {
            if (value.identifier.name != 'none') {
              return; // Meaningful clipBehavior
            }
          } else if (value is PropertyAccess) {
            if (value.propertyName.name != 'none') {
              return; // Meaningful clipBehavior
            }
          } else {
            // If we can't determine the value, assume it's meaningful
            return;
          }
        }
      }
    }

    // If we reach here, Container only has child (and possibly key)
    rule.reportAtNode(node);
  }

  bool _hasArgument(InstanceCreationExpression node, String name) {
    for (final arg in node.argumentList.arguments) {
      if (arg is NamedExpression && arg.name.label.name == name) {
        return true;
      }
    }
    return false;
  }
}
