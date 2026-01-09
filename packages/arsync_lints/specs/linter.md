# PRD: Arsync Solutions Custom Linter (`arsync_lints`)

## 1. Overview

The **`arsync_lints`** package is a static analysis tool that enforces the "Arsync Law"—a 4-layer architecture (Presentation, ViewModel, Model, Repository) with strict separation of concerns, Riverpod best practices, and clean code standards.

**Primary Goal:** Eliminate "spaghetti code" and architectural drift by treating pattern violations as **Build Errors**, not just warnings.

---

## 2. Global Configuration

* **Severity:** **ERROR** (Red Squiggle) for all architectural violations. The CI/CD pipeline must fail if any errors exist.
* **Scope:** Applies to `lib/`. The `test/` folder is exempt ("Wild West").
* **Suppression:** `// ignore_for_file:` is **BANNED**. Developers must fix the issue or use line-specific ignores (`// ignore: rule_id`) for rare exceptions.

---

## 3. Rules Specification

### Category A: Architectural Layer Isolation

*These rules prevent layers from "leaking" into each other.*

#### Rule A1: `presentation_layer_isolation`

* **Description:** Files in `lib/screens/` and `lib/widgets/` cannot import Infrastructure, Repositories, or Data Sources.
* **Logic:**
* Target: Files inside `lib/screens/*` or `lib/widgets/*`.
* Banned Imports: `package:*/repositories/*`, `package:cloud_firestore/*`, `package:http/*`, `package:dio/*`.


* **Correction:** Move logic to a ViewModel (Provider) and watch the provider instead.

#### Rule A2: `shared_widget_purity`

* **Description:** "Shared Widgets" (the design system) must be dumb and pure. They cannot know about business logic.
* **Logic:**
* Target: Files inside `lib/widgets/*`.
* Banned Imports: `package:*/providers/*`, `package:flutter_riverpod/*`.


* **Correction:** Pass data as parameters (Constructor Arguments) instead of reading providers.

#### Rule A3: `model_purity`

* **Description:** Models are pure data structures. They cannot contain business logic or UI code.
* **Logic:**
* Target: Files inside `lib/models/*`.
* Banned Imports: `package:*/providers/*`, `package:*/screens/*`, `package:flutter_riverpod/*`.
* **Requirement:** Class must be annotated with `@freezed`.
* **Requirement:** Class must have a `fromJson` factory.


* **Correction:** Remove logic or move it to a ViewModel.

#### Rule A4: `repository_isolation`

* **Description:** Repositories handle data fetching only. They cannot manage state or UI.
* **Logic:**
* Target: Files inside `lib/repositories/*`.
* Banned Imports: `package:*/screens/*`, `package:*/providers/*` (Circular dependency prevention).
* **Allowed:** Importing other repositories (Dependency Injection) is permitted.



---

### Category B: Riverpod & State Management

*These rules enforce the "Arsync Riverpod Pattern".*

#### Rule B1: `provider_autodispose_enforcement`

* **Description:** To prevent memory leaks, all providers must use `.autoDispose` by default.
* **Logic:**
* Target: Any variable ending in `Provider` inside `lib/providers/`.
* Check: Must contain `.autoDispose`.
* **Exception:** If the provider calls `ref.keepAlive()`, the rule is satisfied (requires AST analysis to check for keepAlive usage).



#### Rule B2: `viewmodel_naming_convention`

* **Description:** Enforce naming consistency for state management.
* **Logic:**
* Target: Files in `lib/providers/`.
* Requirement: Classes extending `Notifier` or `AsyncNotifier` must end with `Notifier`.
* Requirement: The global provider variable must end with `Provider`.



#### Rule B3: `no_context_in_providers`

* **Description:** ViewModels must be UI-agnostic.
* **Logic:**
* Target: Files in `lib/providers/`.
* Banned Type: `BuildContext` cannot be used as a parameter in any function or constructor.



#### Rule B4: `async_viewmodel_safety`

* **Description:** Async operations in ViewModels must handle errors explicitly.
* **Logic:**
* Target: Methods inside `Notifier` / `AsyncNotifier` classes.
* Check: If method body contains `await`, it **MUST** be wrapped in `try/catch`.
* **Secondary Check (Warning/Info):** The `catch` block should contain `ref.showExceptionSheet(e)`. If missing, developer must add `// ignore: async_viewmodel_safety` with a comment explaining why.



---

### Category C: Repository & Data Integrity

#### Rule C1: `repository_no_try_catch`

* **Description:** Repositories must throw errors to the ViewModel, not swallow them.
* **Logic:**
* Target: Files inside `lib/repositories/*`.
* Banned Syntax: `try { ... } catch (e) { ... }`.


* **Correction:** Remove the try-catch block. Let the exception bubble up.

#### Rule C2: `repository_async_return`

* **Description:** Repositories must not block the main thread.
* **Logic:**
* Target: Public methods inside `Repository` classes.
* Requirement: Return type must be `Future<T>` or `Stream<T>`.



---

### Category D: Code Quality & Complexity (The "Clean Code" Rules)

#### Rule D1: `complexity_limits`

* **Description:** Prevents complex, unreadable code.
* **Logic:**
* **Max Method Parameters:** 4.
* **Max Nesting Depth:** 3 (e.g., `if` inside `for` inside `if` is max).
* **Max Build Method Lines:** 100 lines.
* **Nested Ternary:** `a ? b : c ? d : e` is **BANNED**.



#### Rule D2: `global_variable_restriction`

* **Description:** No global state pollution.
* **Logic:**
* Target: Top-level variables.
* **Allowed:**
* Variables starting with `_` (file-private).
* Variables inside `lib/utils/constants.dart` starting with `k` (e.g., `kAnimationDuration`).
* Riverpod Providers (defined in `lib/providers/`).


* **Banned:** Everything else.



#### Rule D3: `print_ban`

* **Description:** Production apps should not spam the console.
* **Logic:**
* Banned: `print()`, `debugPrint()`.
* Allowed: `.log()` (Your custom extension).



#### Rule D4: `barrel_file_restriction`

* **Description:** Explicit imports are preferred to maintain layer visibility.
* **Logic:**
* Target: Files named `index.dart` or files that only contain `export` statements.
* **Banned Location:** `lib/screens/`, `lib/features/`, `lib/providers/`.
* **Allowed Location:** `lib/utils/`, `lib/widgets/`, `lib/models/`.



#### Rule D5: `ignore_file_ban`

* **Description:** Developers cannot lazily disable rules for an entire file.
* **Logic:**
* Search for string: `// ignore_for_file:`
* Result: **ERROR**.



---

### Category E: UI Safety & Consistency

#### Rule E1: `hook_safety_enforcement`

* **Description:** Hooks must be used correctly to prevent runtime crashes.
* **Logic:**
* Target: Function calls starting with `use` (e.g., `useTextEditingController`).
* Requirement: Must be inside the `build()` method of a `HookConsumerWidget`.
* **Ban:** Instantiating `TextEditingController`, `AnimationController`, or `ScrollController` directly in `build` without using a hook.



#### Rule E2: `scaffold_location`

* **Description:** Pages live in screens; Fragments live in widgets.
* **Logic:**
* Target: Files inside `lib/widgets/`.
* Banned Widget: `Scaffold`.


* **Correction:** Use `Container`, `Column`, or `PrimaryCard` instead.

#### Rule E3: `asset_safety`

* **Description:** Prevent typos in asset paths.
* **Logic:**
* Target: `Image.asset()`, `SvgPicture.asset()`.
* Banned Argument: String literals (e.g., `'assets/logo.png'`).
* Requirement: Must use `Images.*` from `lib/utils/images.dart`.



#### Rule E4: `file_class_match`

* **Description:** Enforce strict naming correspondence.
* **Logic:**
* If file is `login_screen.dart`, Class **MUST** be `LoginScreen`.
* If file is `auth_repository.dart`, Class **MUST** be `AuthRepository`.



---

### 4. Implementation Example (Mental Model)

When a developer tries to commit this code:

```dart
// lib/screens/home/home_screen.dart

// Violation A1: UI importing Repo
import 'package:arsync/repositories/auth_repository.dart'; 

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Violation D3: Print statement
    print("Building Home"); 
    
    // Violation A1/B3: Calling Repo directly
    final repo = AuthRepository(); 

    return Scaffold(
      // Violation D1: Nested Ternary
      body: isLoading ? Loading() : hasError ? Error() : Content(), 
    );
  }
}

```

**`arsync_lints` Output:**

```text
[ERROR] presentation_layer_isolation: UI cannot import Repositories. (lib/screens/home/home_screen.dart:3)
[ERROR] print_ban: Use .log() extension instead of print. (lib/screens/home/home_screen.dart:8)
[ERROR] complexity_limits: Nested ternary operators are banned. (lib/screens/home/home_screen.dart:15)

```

The build will **FAIL**. The developer cannot proceed until the architecture is respected.