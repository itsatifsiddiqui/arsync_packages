# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

`arsync_lints` is a custom Dart lint package built on `custom_lint_builder` that enforces the Arsync 4-Layer Architecture. It treats architectural violations as **build errors**, not warnings.

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
cd example && dart run custom_lint
```

## Architecture

### How custom_lint Works

1. Entry point: `lib/arsync_lints.dart` exports `createPlugin()` which returns the plugin instance
2. Plugin registers all `LintRule` classes in `getLintRules()`
3. Each rule extends `DartLintRule` and implements `run()` to analyze AST nodes
4. Rules use `context.registry.add*()` to listen for specific AST node types
5. Violations are reported via `reporter.atNode()` or `reporter.atToken()`

### Rule Structure

```
lib/
├── arsync_lints.dart          # Plugin entry point, registers all rules
└── src/
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
2. Extend `DartLintRule` with a `const` constructor
3. Define `LintCode` constants for error messages
4. Implement `run()` using `context.registry.add*()` callbacks
5. Register in `lib/arsync_lints.dart` `getLintRules()`
6. Add tests to `test/lint_rules_test.dart`
7. Add example violations to `example/lib/`

### LintCode Definition

```dart
static const _code = LintCode(
  name: 'rule_name',  // Must be snake_case
  problemMessage: 'What is wrong.',
  correctionMessage: 'How to fix it.',
);
```

### AST Visitors

For complex traversal within a node (e.g., finding all method calls in a build method):
```dart
final visitor = _MyVisitor(reporter, code);
body.accept(visitor);

class _MyVisitor extends RecursiveAstVisitor<void> {
  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    // Check node
    super.visitInstanceCreationExpression(node);
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
- Max 3 nesting levels
- Max 60 lines per method
- Max 120 lines for `build()` methods
- Nested ternary operators banned

## Special Cases

- `providers/core/` is exempt from autodispose enforcement (infrastructure providers)
- `constants.dart` allows `k`-prefixed global variables and functions
- `main()` function is always allowed
- Private (`_`) prefixed items are generally exempt from naming rules
