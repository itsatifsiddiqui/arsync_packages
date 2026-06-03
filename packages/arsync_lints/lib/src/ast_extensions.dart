import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';

/// Widget base classes a `lib/widgets/` or `lib/screens/` class is expected
/// to extend. Shared between `presentation_layer_isolation` and
/// `shared_widget_purity`.
const widgetBaseClasses = {
  'StatelessWidget',
  'StatefulWidget',
  'HookWidget',
  'HookConsumerWidget',
  'ConsumerWidget',
  'ConsumerStatefulWidget',
  'State',
};

extension ClassDeclarationX on ClassDeclaration {
  /// The class name token. In analyzer 13 it lives in `namePart`; this getter
  /// hides the unwrapping (we assume the common `NameWithTypeParameters` form,
  /// which covers all class declarations not using a primary constructor).
  Token get className => (namePart as NameWithTypeParameters).typeName;

  /// The class members. In analyzer 13 they moved into `body`, but `body` is
  /// `ClassBody` (sealed); the common concrete form is `BlockClassBody`.
  NodeList<ClassMember> get classMembers =>
      (body as BlockClassBody).members;

  /// The closing `}` of the class body.
  Token get bodyRightBracket => (body as BlockClassBody).rightBracket;

  /// The bare lexeme of the superclass name, or `null` if there's no
  /// `extends` clause.
  String? get superclassName => extendsClause?.superclass.name.lexeme;

  /// True if the class is annotated `@freezed` or `@Freezed(...)`.
  bool get hasFreezedAnnotation => metadata.any((a) {
    final n = a.name.name;
    return n == 'freezed' || n == 'Freezed';
  });

  /// True if the superclass name contains "Notifier" — matches `Notifier`,
  /// `AsyncNotifier`, `AutoDisposeFamilyNotifier`, etc.
  bool get extendsNotifierVariant =>
      superclassName?.contains('Notifier') ?? false;

  /// True if the superclass is one of [widgetBaseClasses].
  bool get extendsWidgetBase => widgetBaseClasses.contains(superclassName);
}

extension InstanceCreationX on InstanceCreationExpression {
  /// The constructor's type name, e.g. `Container` for `Container(...)`.
  ///
  /// Reads the AST token directly — does NOT trigger type resolution. Prefer
  /// this over `staticType?.getDisplayString()` for widget identity checks;
  /// the analyzer tutorial notes that AST getters are "often the most
  /// efficient way" of traversing.
  String get typeName => constructorName.type.name.lexeme;

  /// First named argument with the given label, or `null`. Hand-rolled loop
  /// to avoid the iterator allocations of `whereType().where().firstOrNull`.
  NamedExpression? namedArg(String name) {
    for (final a in argumentList.arguments) {
      if (a is NamedExpression && a.name.label.name == name) return a;
    }
    return null;
  }
}

extension AstNodeX on AstNode {
  /// First enclosing `InstanceCreationExpression` whose lexical type name
  /// equals [typeName] (e.g. `Container`, `Padding`).
  InstanceCreationExpression? ancestorWidget(String typeName) =>
      thisOrAncestorMatching(
            (n) =>
                n is InstanceCreationExpression &&
                n.constructorName.type.name.lexeme == typeName,
          )
          as InstanceCreationExpression?;
}
