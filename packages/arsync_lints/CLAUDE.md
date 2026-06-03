# CLAUDE.md

`arsync_lints` is a `analysis_server_plugin`-based lint package enforcing the
Arsync 4-Layer Architecture (presentation, viewmodel/providers, repositories,
models) plus Riverpod and Flutter best practices.

## Layout

```
lib/
├── main.dart                  # Plugin entry point; exports `plugin`.
└── src/
    ├── arsync_lint_rule.dart  # Single import for rules (re-exports analyzer + helpers).
    ├── ast_extensions.dart    # ClassDeclarationX, InstanceCreationX, AstNodeX.
    ├── banned_import_visitor.dart  # Shared visitor for import-banning rules.
    ├── rule_visitor_base.dart # `ArsyncRuleVisitor<R>` — the visitor base class.
    ├── utils.dart             # PathUtils, ImportUtils.
    ├── rules/                 # One file per rule.
    └── fixes/                 # One file per quick-fix (+ fix_helpers.dart).
```

## Conventions

- **One `_Visitor` per rule, instantiated once** in `registerNodeProcessors`
  and registered for every node type the rule cares about.
- **Visitor extends `ArsyncRuleVisitor<R>`** (where `R` is `AnalysisRule` or
  `MultiAnalysisRule`). Don't extend `SimpleAstVisitor` directly.
- **`RuleContext.isInLibDir` / `isInTestDirectory` / `currentUnit`** —
  use these directly. Don't reimplement.
- **AST extensions over inline walks**: `node.hasFreezedAnnotation`,
  `node.extendsNotifierVariant`, `node.extendsWidgetBase`, `node.typeName`,
  `node.namedArg('child')`, `node.ancestorWidget('Padding')`. Plus the
  analyzer-12-compat shims: `classDecl.className` (the class-name `Token`,
  unwraps `namePart`), `classDecl.classMembers` (unwraps `body`),
  `classDecl.bodyRightBracket`.
- **Syntactic over semantic**: `node.constructorName.type.name.lexeme` (i.e.
  `typeName` extension) — not `staticType?.getDisplayString()` — for widget
  identity checks. The semantic path triggers type resolution.
- **Static `const Set`s** for membership checks. Inline `RegExp` literals
  belong in `static final` fields so they compile once.
- **Generated files are excluded by the user's `analysis_options.yaml`** —
  rules do NOT filter generated files in code.

## Adding a new lint rule (warning + quick fix)

1. **Rule file** `lib/src/rules/<name>.dart`:
   ```dart
   import '../arsync_lint_rule.dart';

   class MyRule extends AnalysisRule {
     MyRule() : super(name: code.name, description: code.problemMessage);

     static const LintCode code = LintCode(
       'my_rule',
       'What is wrong.',
       correctionMessage: 'How to fix it.',
     );

     @override
     DiagnosticCode get diagnosticCode => code;

     @override
     void registerNodeProcessors(RuleVisitorRegistry registry, RuleContext context) {
       if (!PathUtils.isInWidgets(context.definingUnit.file.path)) return; // path gate
       registry.addInstanceCreationExpression(this, _Visitor(this));
     }
   }

   class _Visitor extends ArsyncRuleVisitor<AnalysisRule> {
     _Visitor(super.rule);
     @override
     void visitInstanceCreationExpression(InstanceCreationExpression node) {
       if (node.typeName != 'Bad') return;
       rule.reportAtNode(node);
     }
   }
   ```
   For rules with multiple diagnostics, extend `MultiAnalysisRule` and pass a
   `diagnosticCode:` arg to `reportAtNode` / `reportAtOffset`.

2. **Fix file** `lib/src/fixes/<name>_fix.dart`:
   ```dart
   class MyRuleFix extends ResolvedCorrectionProducer {
     MyRuleFix({required super.context});
     static const _fixKind = FixKind('arsync.fix.myRule', 100, 'Fix it');
     @override FixKind? get fixKind => _fixKind;
     @override CorrectionApplicability get applicability => CorrectionApplicability.singleLocation;
     @override Future<void> compute(ChangeBuilder b) async {
       final widget = node.ancestorWidget('Bad');
       if (widget == null) return;
       await b.addDartFileEdit(file, (e) => e.addDeletion(SourceRange(widget.offset, widget.length)));
     }
   }
   ```
   Use `FixHelpers.deleteLine` / `FixHelpers.indentOf` for line/indent ops.

3. **Register both** in `lib/main.dart`: add `MyRule()` to the rules list and
   `registry.registerFixForRule(MyRule.code, MyRuleFix.new)`.

4. **Tests** `test/rules/<name>_test.dart` (see existing tests for shape).

## Notes on analyzer version

We track `analyzer ^12.0.0` (rolled back from 13 because the wider ecosystem —
`freezed`, `json_serializable` — hadn't caught up). Things to know about 12:

- `ClassDeclaration.members` / `.name` / `.rightBracket` were moved into `.body`
  (`ClassBody`) and `.namePart` (`ClassNamePart`). The `ClassDeclarationX`
  extensions expose `className`, `classMembers`, `bodyRightBracket` so callers
  don't deal with the unwrap.
- Named arguments are still `NamedExpression` (not `NamedArgument` — that's an
  analyzer 13 rename). Use `namedExpr.name.label.name` to read the label and
  `namedExpr.expression` for the inner value.
- `argumentList.arguments` still returns `List<Expression>` (sealed `Argument`
  is analyzer 13). For positional arguments treat the element directly as
  `Expression`.
- `SimpleFormalParameter` and `DefaultFormalParameter` still apply — the
  `RegularFormalParameter` consolidation is analyzer 13.
- `LintCode.name` is deprecated → use `lowerCaseName` (our codes are already
  lowercase snake_case).

`analyzer_plugin` is imported transitively (via `analysis_server_plugin`) for
`FixKind` and `ChangeBuilder`. We don't declare it directly; the
`depend_on_referenced_packages` lint is suppressed in `analysis_options.yaml`.