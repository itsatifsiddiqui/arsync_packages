# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

`arsync_lints` is a custom Dart lint package built on the native `analysis_server_plugin` system (Dart 3.10+) that enforces the Arsync 4-Layer Architecture. It treats architectural violations as **build errors**, not warnings.

## Requirements

- **Dart SDK**: 3.10.0 or higher
- **Flutter SDK**: 3.38.0 or higher

## Commands

```bash
# Run all tests
dart test

# Run a single test file
dart test test/lint_rules_test.dart

# Run a specific test by name
dart test --name "ComplexityLimits"

# Analyze the package
dart analyze

# Test lints in the example project
cd example && dart analyze
```

## Architecture

### How analysis_server_plugin Works

1. Entry point: `lib/main.dart` exports a top-level `plugin` variable
2. Plugin class `ArsyncPlugin` extends `ServerPlugin` and registers all rules
3. Each rule extends `AnalysisRule` or `MultiAnalysisRule` and implements `registerNodeProcessors()`
4. Rules use `registry.add*()` to listen for specific AST node types
5. Violations are reported via `rule.reportAtNode()` or `rule.reportAtOffset()`

### Rule Structure

```
lib/
├── main.dart              # Plugin entry point, exports `plugin` variable
├── arsync_plugin.dart     # ArsyncPlugin class, registers all rules
├── arsync_lints.dart      # Library exports for programmatic access
└── src/
    ├── arsync_lint_rule.dart  # Base rule classes and helpers
    ├── utils.dart             # PathUtils, ImportUtils helpers
    └── rules/                 # 27 lint rules organized by category
        ├── presentation_layer_isolation.dart   # Category A
        ├── provider_autodispose_enforcement.dart  # Category B
        ├── repository_no_try_catch.dart        # Category C
        ├── complexity_limits.dart              # Category D
        └── hook_safety_enforcement.dart        # Category E
```

### Rule Categories

- **Category A (4 rules)**: Architectural Layer Isolation - prevents cross-layer imports
- **Category B (9 rules)**: Riverpod & State Management - enforces provider patterns
- **Category C (5 rules)**: Repository & Data Integrity - repository conventions
- **Category D (5 rules)**: Code Quality & Complexity - clean code standards
- **Category E (4 rules)**: UI Safety & Consistency - widget/hook patterns

### Path-Based Rule Targeting

Rules use `PathUtils` to determine file location:
- `isInScreens()` - `lib/screens/`
- `isInWidgets()` - `lib/widgets/`
- `isInProviders()` - `lib/providers/`
- `isInRepositories()` - `lib/repositories/`
- `isInModels()` - `lib/models/`
- `isConstantsFile()` - `**/constants.dart`

### Post-Run Callbacks

For rules that need to collect data across the entire file before validating (e.g., checking for single provider per file), use:
```dart
context.addPostRunCallback(() {
  // Validation logic after all AST nodes processed
});
```

## Key Patterns

### Creating a New Rule

1. Create `lib/src/rules/rule_name.dart`
2. Extend `AnalysisRule` (single diagnostic) or `MultiAnalysisRule` (multiple diagnostics)
3. Define `LintCode` constants for error messages
4. Implement `registerNodeProcessors()` using `registry.add*()` callbacks
5. Register in `lib/arsync_plugin.dart` `getLintRules()` method
6. Add tests to `test/rules/` directory
7. Add example violations to `example/lib/`

### LintCode Definition

```dart
static const LintCode code = LintCode(
  'rule_name',  // Must be snake_case
  'What is wrong.',
  correctionMessage: 'How to fix it.',
);
```

### AST Visitors

For complex traversal within a node (e.g., finding all method calls in a build method):
```dart
final visitor = _MyVisitor(rule);
body.accept(visitor);

class _MyVisitor extends RecursiveAstVisitor<void> {
  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    // Check node
    super.visitInstanceCreationExpression(node);
  }
}
```

### Quick Fixes

To add a quick fix for a rule:
1. Create `lib/src/fixes/rule_name_fix.dart`
2. Extend `ResolvedCorrectionProducer`
3. Define `FixKind` with priority
4. Implement `compute()` to build the fix
5. Register in `ArsyncPlugin.register()` using `registry.registerFixForRule()`

Example:
```dart
class MyRuleFix extends ResolvedCorrectionProducer {
  static const _fixKind = FixKind(
    'arsync.fix.myRule',
    100, // Priority
    'Fix description',
  );

  @override
  Future<void> compute(ChangeBuilder builder) async {
    // Build the fix
  }
}
```

## Testing

Tests use the `analyzer_testing` package with `test_reflective_loader`:

```dart
@reflectiveTest
class MyRuleTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = MyRule();
    super.setUp();
  }

  Future<void> test_good_case() async {
    await assertNoDiagnostics(r'''
void main() {}
''');
  }

  Future<void> test_bad_case() async {
    await assertDiagnostics(r'''
void badCode() {}
''', [lint(0, 17)]);
  }
}
```

## Example Project

The `example/` directory contains:
- `lib/screens/bad_screen.dart` - Demonstrates rule violations
- `lib/screens/good_screen.dart` - Demonstrates compliant code
- `lib/providers/`, `lib/repositories/`, `lib/models/` - Pattern examples

## Complexity Limits

- Max 4 method parameters
- Max 5 nesting levels
- Max 60 lines per method
- Max 120 lines for `build()` methods
- Nested ternary operators banned

## Special Cases

- `providers/core/` is exempt from autodispose enforcement (infrastructure providers)
- `constants.dart` allows `k`-prefixed global variables and functions
- `main()` function is always allowed
- Private (`_`) prefixed items are generally exempt from naming rules
