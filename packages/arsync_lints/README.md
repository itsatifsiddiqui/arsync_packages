# arsync_lints

A powerful lint package for Flutter/Dart that enforces the **Arsync 4-Layer Architecture** with strict separation of concerns, Riverpod best practices, and clean code standards.

[![Dart](https://img.shields.io/badge/Dart-3.10+-blue.svg)](https://dart.dev)
[![Flutter](https://img.shields.io/badge/Flutter-3.38+-02569B.svg)](https://flutter.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

## Requirements

- **Dart SDK**: 3.10.0 or higher
- **Flutter SDK**: 3.38.0 or higher

This package uses the native `analysis_server_plugin` system introduced in Dart 3.10, which provides better IDE integration and faster analysis compared to the legacy custom_lint approach.

## Overview

`arsync_lints` treats architectural violations as **build errors**, not warnings. This ensures your codebase maintains clean architecture from day one and prevents "spaghetti code" from creeping into your project.

## Installation

### 1. Add to your `pubspec.yaml`

```yaml
dev_dependencies:
  arsync_lints: ^1.0.0
```

### 2. Enable the plugin in `analysis_options.yaml`

```yaml
# Dart 3.10+ native plugin system
plugins:
  arsync_lints:

analyzer:
  exclude:
    - '**/*.g.dart'
    - '**/*.freezed.dart'
```

**Note:** The `plugins:` section is a top-level key, not nested under `analyzer:`.

### 3. Restart your IDE

After adding the plugin, restart your IDE (VS Code, Android Studio, IntelliJ) to activate the lints. The diagnostics will appear automatically in your editor.

### 4. Run analysis

```bash
# Analyze your project
dart analyze
```

## Rules Reference

### Category A: Architectural Layer Isolation

These rules prevent layers from "leaking" into each other.

| Rule | Target | Description |
|------|--------|-------------|
| `presentation_layer_isolation` | `screens/`, `widgets/` | Cannot import repositories, cloud_firestore, http, or dio. Use Dart records instead of parameter classes. |
| `shared_widget_purity` | `widgets/` | Cannot import providers or Riverpod packages. Each file must have only ONE public widget. |
| `model_purity` | `models/` | Must use @freezed and have fromJson factory; no provider imports |
| `repository_isolation` | `repositories/` | Cannot import screens or UI-specific Riverpod (flutter_riverpod, hooks_riverpod) |

#### Example: presentation_layer_isolation

```dart
// NOT RECOMMENDED - lib/screens/home_screen.dart
import 'package:my_app/repositories/auth_repository.dart'; // ERROR!
import 'package:dio/dio.dart'; // ERROR!

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final repo = AuthRepository(); // Direct repo access!
    return Container();
  }
}

// RECOMMENDED - lib/screens/home_screen.dart
import 'package:my_app/providers/auth_provider.dart';

class HomeScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider); // Watch provider instead
    return Container();
  }
}
```

#### Example: shared_widget_purity (Single Widget Per File)

```dart
// NOT RECOMMENDED - lib/widgets/buttons.dart
class PrimaryButton extends StatelessWidget {} // ALLOWED - first public widget
class SecondaryButton extends StatelessWidget {} // ERROR! Multiple public widgets

// RECOMMENDED - lib/widgets/primary_button.dart
class PrimaryButton extends StatelessWidget {}
class _ButtonContent extends StatelessWidget {} // ALLOWED - private helper
```

#### Example: Use Records Instead of Parameter Classes

```dart
// NOT RECOMMENDED - lib/screens/profile_screen.dart
class UpdateProfileParams {
  final String userId;
  final String name;
  const UpdateProfileParams({required this.userId, required this.name});
}

// RECOMMENDED - Use Dart records
typedef UpdateProfileParams = ({
  String userId,
  String name,
  String? phone,
});

// Usage
void updateProfile(UpdateProfileParams params) {
  print(params.userId);
}
```

#### Example: model_purity

```dart
// NOT RECOMMENDED - lib/models/user.dart
import 'package:riverpod/riverpod.dart'; // ERROR: No provider imports in models!

class User {
  final String name;
  User(this.name);
}

// RECOMMENDED - lib/models/user.dart
@freezed
class User with _$User {
  const factory User({
    required String id,
    required String name,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
```

#### Example: repository_isolation

```dart
// NOT RECOMMENDED - lib/repositories/user_repository.dart
import 'package:flutter_riverpod/flutter_riverpod.dart'; // ERROR: UI Riverpod!
import 'package:my_app/screens/home_screen.dart'; // ERROR: Screen import!

// RECOMMENDED - lib/repositories/user_repository.dart
import 'package:riverpod/riverpod.dart'; // ALLOWED: Core Riverpod only
import 'package:dio/dio.dart';

class UserRepository {
  final Dio _dio;
  UserRepository(this._dio);
}
```

---

### Category B: Riverpod & State Management

These rules enforce the "Arsync Riverpod Pattern".

| Rule | Target | Description |
|------|--------|-------------|
| `provider_autodispose_enforcement` | `providers/` | Providers must use `.autoDispose` or call `ref.keepAlive()`. |
| `provider_file_naming` | `providers/` | Files must end with `_provider.dart` and contain a matching Notifier class |
| `provider_state_class` | `providers/` | State classes must be @freezed and defined in the same file |
| `provider_declaration_syntax` | `providers/` | Must use `.new` constructor syntax (e.g., `AuthNotifier.new`) |
| `provider_class_restriction` | `providers/` | Only Notifier classes and @freezed state classes allowed |
| `provider_single_per_file` | `providers/` | Each file can only have ONE NotifierProvider matching the file name |
| `viewmodel_naming_convention` | `providers/` | Notifier classes must end with "Notifier" |
| `no_context_in_providers` | `providers/` | BuildContext cannot be used as a parameter |
| `async_viewmodel_safety` | `providers/` | Async methods in Notifiers must have try/catch |

#### Example: provider_file_naming

```dart
// File: lib/providers/auth_provider.dart

// RECOMMENDED
class AuthNotifier extends Notifier<AuthState> { ... } // Matches file name prefix

// NOT RECOMMENDED - lib/providers/auth.dart (missing _provider suffix)
// NOT RECOMMENDED - lib/providers/auth_provider.dart with class UserNotifier (prefix mismatch)
```

#### Example: provider_declaration_syntax

```dart
// NOT RECOMMENDED - Explicit generics and closure
final authProvider = NotifierProvider.autoDispose<AuthNotifier, AuthState>(
  () => AuthNotifier(),
);

// RECOMMENDED - Clean .new syntax
final authProvider = NotifierProvider.autoDispose(AuthNotifier.new);
```

#### Example: provider_autodispose_enforcement

```dart
// NOT RECOMMENDED - Memory leak potential
final authProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
}); // ERROR: Missing autoDispose

// RECOMMENDED - Option 1: Use autoDispose
final authProvider = NotifierProvider.autoDispose(AuthNotifier.new);

// RECOMMENDED - Option 2: Use keepAlive for persistent state
final authProvider = NotifierProvider.autoDispose(AuthNotifier.new);

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    ref.keepAlive(); // Explicitly opt-in to persistence
    return AuthState();
  }
}
```

#### Example: provider_state_class

```dart
// NOT RECOMMENDED - State class not @freezed
class AuthState {
  final bool isLoggedIn;
  AuthState(this.isLoggedIn);
}

// RECOMMENDED - Immutable state with @freezed
@freezed
class AuthState with _$AuthState {
  const factory AuthState({
    @Default(false) bool isLoggedIn,
    User? user,
  }) = _AuthState;
}
```

#### Example: provider_single_per_file

```dart
// NOT RECOMMENDED - lib/providers/auth_provider.dart
final authProvider = NotifierProvider.autoDispose(AuthNotifier.new);
final userProvider = NotifierProvider.autoDispose(UserNotifier.new); // ERROR!

// RECOMMENDED - One provider per file
// lib/providers/auth_provider.dart -> authProvider
// lib/providers/user_provider.dart -> userProvider
```

#### Example: async_viewmodel_safety

```dart
// NOT RECOMMENDED - Unhandled async errors
class UserNotifier extends AsyncNotifier<User> {
  Future<void> fetchUser() async {
    await userRepository.getUser(); // ERROR: No try/catch
  }
}

// RECOMMENDED - Proper error handling
class UserNotifier extends AsyncNotifier<User> {
  Future<void> fetchUser() async {
    try {
      await userRepository.getUser();
    } catch (e) {
      ref.showExceptionSheet(e);
    }
  }
}
```

#### Example: viewmodel_naming_convention

```dart
// NOT RECOMMENDED - lib/providers/auth_provider.dart
class AuthViewModel extends Notifier<AuthState> {} // ERROR: Must end with "Notifier"
class Auth extends Notifier<AuthState> {} // ERROR: Must end with "Notifier"

// RECOMMENDED
class AuthNotifier extends Notifier<AuthState> {} // Correct naming
class UserAuthNotifier extends Notifier<AuthState> {} // Also correct
```

#### Example: no_context_in_providers

```dart
// NOT RECOMMENDED - BuildContext in provider method
class AuthNotifier extends Notifier<AuthState> {
  void showError(BuildContext context) { // ERROR: No BuildContext!
    ScaffoldMessenger.of(context).showSnackBar(...);
  }
}

// RECOMMENDED - UI-agnostic, let the UI handle presentation
class AuthNotifier extends Notifier<AuthState> {
  void setError(String message) {
    state = state.copyWith(errorMessage: message);
  }
}
```

#### Example: provider_class_restriction

```dart
// NOT RECOMMENDED - lib/providers/auth_provider.dart
class AuthHelper {} // ERROR: Only Notifier classes allowed
class AuthUtils {} // ERROR: Move to utils/

@freezed
class AuthState with _$AuthState {} // ALLOWED: @freezed state class

// RECOMMENDED - Only Notifier and @freezed state classes
class AuthNotifier extends Notifier<AuthState> {}

@freezed
class AuthState with _$AuthState {
  const factory AuthState({...}) = _AuthState;
}
```

---

### Category C: Repository & Data Integrity

| Rule | Target | Description |
|------|--------|-------------|
| `repository_provider_declaration` | `repositories/` | Must define a Provider ending with `RepoProvider` |
| `repository_dependency_injection` | `repositories/` | Dependencies must be injected via constructor; `Ref` parameter banned |
| `repository_class_restriction` | `repositories/` | Only classes with "Repository" in name; files must end with `_repository.dart` |
| `repository_no_try_catch` | `repositories/` | Repositories must throw errors, not catch them |
| `repository_async_return` | `repositories/` | Public methods must return `Future<T>` or `Stream<T>` |

#### Example: repository_provider_declaration

```dart
// lib/repositories/auth_repository.dart

// RECOMMENDED - Provider at top ending with RepoProvider
final authRepoProvider = Provider<AuthRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return AuthRepository(dio);
});

class AuthRepository {
  final Dio _dio;
  AuthRepository(this._dio);
}
```

#### Example: repository_dependency_injection

```dart
// NOT RECOMMENDED - Direct instantiation
class AuthRepository {
  final Dio _dio = Dio(); // ERROR: Create objects directly
}

// NOT RECOMMENDED - Ref parameter
class AuthRepository {
  final Ref ref; // ERROR: Ref not allowed
  AuthRepository(this.ref);
}

// RECOMMENDED - Constructor injection
class AuthRepository {
  final Dio _dio;
  AuthRepository(this._dio); // Injected via provider
}
```

#### Example: repository_no_try_catch

```dart
// NOT RECOMMENDED - Swallowing errors
class UserRepository {
  Future<User?> getUser(String id) async {
    try {
      return await api.fetchUser(id);
    } catch (e) {
      return null; // ERROR: Hiding the error!
    }
  }
}

// RECOMMENDED - Let errors bubble up
class UserRepository {
  Future<User> getUser(String id) async {
    return await api.fetchUser(id); // Throws on error
  }
}
```

#### Example: repository_class_restriction

```dart
// NOT RECOMMENDED - lib/repositories/user_helper.dart
class UserHelper {} // ERROR: File must end with _repository.dart

// NOT RECOMMENDED - lib/repositories/user_repository.dart
class UserService {} // ERROR: Class must contain "Repository"

// RECOMMENDED - lib/repositories/user_repository.dart
class UserRepository {
  Future<User> getUser(String id) async { ... }
}

// RECOMMENDED - Private helper classes are allowed
class _UserCacheHelper {} // ALLOWED: Private class
```

#### Example: repository_async_return

```dart
// NOT RECOMMENDED - Synchronous public methods
class UserRepository {
  User getUser(String id) { ... } // ERROR: Must return Future<T>
  List<User> getAllUsers() { ... } // ERROR: Must return Future<T> or Stream<T>
}

// RECOMMENDED - Async public methods
class UserRepository {
  Future<User> getUser(String id) async { ... }
  Stream<List<User>> watchUsers() { ... }

  // Private methods can be sync
  User _parseUser(Map<String, dynamic> json) { ... } // ALLOWED: Private
}
```

---

### Category D: Code Quality & Complexity

| Rule | Description |
|------|-------------|
| `complexity_limits` | Max 4 parameters, max 3 nesting levels, max 60 lines per method, max 120 lines in build(), no nested ternary |
| `global_variable_restriction` | Top-level variables must be private (`_`), constants (`k` prefix), or Providers. Top-level functions must be private, `k`-prefixed (in constants.dart), or `main()` |
| `print_ban` | `print()` and `debugPrint()` are banned; use custom logging using log() extension method on Object |
| `barrel_file_restriction` | No `index.dart` barrel files in screens/, features/, widgets/, or providers/ |
| `ignore_file_ban` | `// ignore_for_file:` comments are banned |

#### Example: complexity_limits

```dart
// NOT RECOMMENDED - Nested ternary
Widget build(BuildContext context) {
  return isLoading
    ? LoadingWidget()
    : hasError
      ? ErrorWidget()  // ERROR: Nested ternary!
      : ContentWidget();
}

// RECOMMENDED - Use if/else or switch
Widget build(BuildContext context) {
  if (isLoading) return LoadingWidget();
  if (hasError) return ErrorWidget();
  return ContentWidget();
}

// NOT RECOMMENDED - Too many parameters (max 4)
void updateUser(
  String id,
  String name,
  String email,
  String phone,
  String address, // ERROR: More than 4 parameters
) {}

// RECOMMENDED - Use a parameter object
void updateUser(UpdateUserParams params) {}

// NOT RECOMMENDED - Method exceeds 60 lines
void processData() {
  // ... 61+ lines of code ... // ERROR!
}

// RECOMMENDED - Extract into smaller methods
void processData() {
  _validateInput();
  _transformData();
  _saveResult();
}
```

#### Example: global_variable_restriction

```dart
// NOT RECOMMENDED - lib/utils/helpers.dart
String globalApiUrl = 'https://api.example.com'; // ERROR!
void helperFunction() {} // ERROR: Top-level function

// RECOMMENDED - lib/utils/constants.dart
const kApiUrl = 'https://api.example.com'; // ALLOWED: k prefix in constants.dart
void kFormatDate() {} // ALLOWED: k prefix in constants.dart

// RECOMMENDED - lib/providers/config_provider.dart
final configProvider = Provider((ref) => Config()); // ALLOWED: Provider variable

// RECOMMENDED - Private functions anywhere
void _internalHelper() {} // ALLOWED: Private function
```

#### Example: print_ban

```dart
// NOT RECOMMENDED - Using print statements
void doSomething() {
  print('Debug info'); // ERROR: Use logging instead
  debugPrint('More debug'); // ERROR: Also banned
}

// RECOMMENDED - Use structured logging
void doSomething() {
  'Debug info'.log(); // Custom log extension
  logger.info('Structured log'); // Logging framework
}
```

#### Example: barrel_file_restriction

```dart
// NOT RECOMMENDED - lib/screens/index.dart (barrel file)
export 'home_screen.dart';
export 'profile_screen.dart';
// ERROR: No barrel files in screens/, widgets/, providers/

// NOT RECOMMENDED - lib/widgets/index.dart
export 'button.dart';
export 'card.dart';
// ERROR: Barrel files are banned

// RECOMMENDED - Import directly
import 'package:my_app/screens/home_screen.dart';
import 'package:my_app/widgets/button.dart';
```

#### Example: ignore_file_ban

```dart
// NOT RECOMMENDED - File-level ignore
// ignore_for_file: print_ban
// ERROR: File-level ignores are banned!

print('This would be ignored'); // But we don't allow this

// RECOMMENDED - Line-specific ignore for rare exceptions
// ignore: print_ban
print('Debug only - remove before commit');
```

---

### Category E: UI Safety & Consistency

| Rule | Target | Description |
|------|--------|-------------|
| `hook_safety_enforcement` | `build()` methods | Controllers must use hooks; `GlobalKey<FormState>()` banned in HookWidgets |
| `scaffold_location` | `widgets/` | Scaffold is not allowed in widgets folder |
| `asset_safety` | All files | Image.asset() must use constants, not string literals |
| `file_class_match` | All files | Class name must match file name (snake_case to PascalCase) |

#### Example: hook_safety_enforcement

```dart
// NOT RECOMMENDED - Memory leak in build
class MyWidget extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController(); // ERROR: Leaks memory!
    return TextField(controller: controller);
  }
}

// RECOMMENDED - Use hooks
class MyWidget extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = useTextEditingController();
    return TextField(controller: controller);
  }
}

// NOT RECOMMENDED - GlobalKey<FormState> resets on keyboard open/orientation change
class MyFormWidget extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = GlobalKey<FormState>(); // ERROR: Resets unexpectedly!
    return Form(key: formKey, child: ...);
  }
}

// RECOMMENDED - Use GlobalObjectKey with context for stable identity
class MyFormWidget extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = GlobalObjectKey<FormState>(context); // Stable across rebuilds
    return Form(key: formKey, child: ...);
  }
}
```

#### Example: scaffold_location

```dart
// NOT RECOMMENDED - lib/widgets/user_card.dart
class UserCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold( // ERROR: Scaffold in widgets/ folder
      body: Text('User info'),
    );
  }
}

// RECOMMENDED - lib/screens/user_screen.dart
class UserScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold( // ALLOWED: Scaffold in screens/ folder
      body: UserCard(),
    );
  }
}

// RECOMMENDED - lib/widgets/user_card.dart
class UserCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card( // ALLOWED: No Scaffold
      child: Text('User info'),
    );
  }
}
```

#### Example: asset_safety

```dart
// NOT RECOMMENDED - Typo-prone string literal
Image.asset('assets/images/logo.png'); // ERROR!

// RECOMMENDED - Use constants
// lib/utils/images.dart
class Images {
  static const logo = 'assets/images/logo.png';
}

// Usage
Image.asset(Images.logo);
```

#### Example: file_class_match

```dart
// File: lib/screens/user_profile_screen.dart

// NOT RECOMMENDED
class ProfilePage {} // ERROR: Should be UserProfileScreen

// RECOMMENDED
class UserProfileScreen {} // Matches file name
```

---

### Category F: Flutter Best Practices

| Rule | Description |
|------|-------------|
| `avoid_consecutive_sliver_to_box_adapter` | Use `SliverList.list()` instead of consecutive `SliverToBoxAdapter` widgets |
| `avoid_hardcoded_color` | Use `Theme.of(context).colorScheme` instead of hardcoded colors |
| `avoid_shrink_wrap_in_list_view` | Avoid `shrinkWrap: true` in ListView; use `SliverList` instead |
| `avoid_single_child` | Don't use `Column`/`Row`/`Stack` with single child; use appropriate widget |
| `prefer_dedicated_media_query_methods` | Use `MediaQuery.sizeOf()` instead of `MediaQuery.of().size` |
| `prefer_space_between_elements` | Require blank lines between class members |
| `prefer_to_include_sliver_in_name` | Widgets returning Slivers should have "Sliver" in name |
| `unsafe_null_assertion` | Avoid force null assertion (`!`); use `??` or null-aware operators |
| `avoid_unnecessary_padding_widget` | Don't wrap Container with Padding; use Container's margin/padding |
| `unnecessary_hook_widget` | Use StatelessWidget instead of HookWidget when no hooks are used |
| `unnecessary_container` | Remove Container when it doesn't use any Container-specific properties |

#### Example: avoid_consecutive_sliver_to_box_adapter

```dart
// NOT RECOMMENDED - Inefficient consecutive SliverToBoxAdapter
CustomScrollView(
  slivers: [
    SliverToBoxAdapter(child: Text('Item 1')),
    SliverToBoxAdapter(child: Text('Item 2')),
    SliverToBoxAdapter(child: Text('Item 3')),
  ],
)

// RECOMMENDED - Use SliverList.list
CustomScrollView(
  slivers: [
    SliverList.list(
      children: [
        Text('Item 1'),
        Text('Item 2'),
        Text('Item 3'),
      ],
    ),
  ],
)
```

#### Example: avoid_hardcoded_color

```dart
// NOT RECOMMENDED - Hardcoded colors don't adapt to themes
Container(color: Color(0xFF00FF00))
Container(color: Colors.red)

// RECOMMENDED - Use theme colors
Container(color: Theme.of(context).colorScheme.primary)
Container(color: Theme.of(context).colorScheme.surface)

// ALLOWED - Transparent is allowed
Container(color: Colors.transparent)
```

#### Example: avoid_shrink_wrap_in_list_view

```dart
// NOT RECOMMENDED - shrinkWrap causes performance issues
ListView(
  shrinkWrap: true, // ERROR: Avoid shrinkWrap
  children: items,
)

// RECOMMENDED - Use SliverList in CustomScrollView
CustomScrollView(
  slivers: [
    SliverList.builder(
      itemCount: items.length,
      itemBuilder: (context, index) => items[index],
    ),
  ],
)
```

#### Example: avoid_single_child

```dart
// NOT RECOMMENDED - Multi-child widget with single child
Column(
  children: [Text('Hello')], // ERROR: Use single-child widget
)

Row(
  children: [Icon(Icons.star)], // ERROR: Unnecessary Row
)

// RECOMMENDED - Use appropriate single-child widgets
Center(child: Text('Hello'))
Align(alignment: Alignment.centerLeft, child: Icon(Icons.star))
```

#### Example: prefer_dedicated_media_query_methods

```dart
// NOT RECOMMENDED - Causes unnecessary rebuilds
Widget build(BuildContext context) {
  final size = MediaQuery.of(context).size; // ERROR!
  final padding = MediaQuery.of(context).padding; // ERROR!
  return Container(width: size.width);
}

// RECOMMENDED - Use dedicated methods (more efficient)
Widget build(BuildContext context) {
  final size = MediaQuery.sizeOf(context);
  final padding = MediaQuery.paddingOf(context);
  return Container(width: size.width);
}
```

#### Example: prefer_space_between_elements

```dart
// NOT RECOMMENDED - No spacing between members
class MyClass {
  final String name;
  final int age;
  void greet() {}
  void farewell() {} // ERROR: Missing blank line before method
}

// RECOMMENDED - Blank lines between members
class MyClass {
  final String name;
  final int age;

  void greet() {}

  void farewell() {}
}
```

#### Example: prefer_to_include_sliver_in_name

```dart
// NOT RECOMMENDED - Returns sliver but name doesn't indicate it
class MyHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter( // ERROR: Name should include "Sliver"
      child: Text('Header'),
    );
  }
}

// RECOMMENDED - Name indicates it returns a sliver
class MySliverHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Text('Header'),
    );
  }
}
```

#### Example: avoid_unnecessary_padding_widget

```dart
// NOT RECOMMENDED - Padding wrapping Container
Padding(
  padding: EdgeInsets.all(16),
  child: Container( // ERROR: Use Container's margin instead
    color: Colors.blue,
    child: Text('Hello'),
  ),
)

// RECOMMENDED - Use Container's margin property
Container(
  margin: EdgeInsets.all(16),
  color: Colors.blue,
  child: Text('Hello'),
)
```

#### Example: unsafe_null_assertion

```dart
// NOT RECOMMENDED - Force null assertion can crash
String getValue(String? name) => name!;

// RECOMMENDED - Use null coalescing
String getValue(String? name) => name ?? 'default';

// RECOMMENDED - Use null-aware access
String? getUserName(User? user) => user?.name;
```

#### Example: unnecessary_hook_widget

```dart
// NOT RECOMMENDED - HookWidget without any hooks
class MyWidget extends HookWidget {
  @override
  Widget build(BuildContext context) => Text('Hello');
}

// RECOMMENDED - Use StatelessWidget when no hooks needed
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Text('Hello');
}

// RECOMMENDED - HookWidget with hooks
class MyWidget extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final controller = useTextEditingController();
    return TextField(controller: controller);
  }
}
```

#### Example: unnecessary_container

```dart
// NOT RECOMMENDED - Container with only child
Container(
  child: Text('Hello'), // ERROR: Container adds no value
)

Container(
  key: Key('myKey'),
  child: Text('Hello'), // ERROR: Only key and child, Container is useless
)

// RECOMMENDED - Just use the widget directly
Text('Hello')

// RECOMMENDED - Container with meaningful properties
Container(
  padding: EdgeInsets.all(8),
  child: Text('Hello'),
)

Container(
  color: Theme.of(context).colorScheme.surface,
  child: Text('Hello'),
)

Container(
  decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
  child: Text('Hello'),
)
```

---

### Category G: Resource Management

| Rule | Target | Description |
|------|--------|-------------|
| `remove_listener` | State classes | Listeners added via `addListener` must be removed in `dispose()` |
| `dispose_notifier` | State classes | ChangeNotifier instances (controllers) must be disposed |

#### Example: remove_listener

```dart
// NOT RECOMMENDED - Listener never removed (memory leak)
class _MyWidgetState extends State<MyWidget> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onChanged); // ERROR!
  }

  void _onChanged() {}

  @override
  Widget build(BuildContext context) => Container();
}

// RECOMMENDED - Properly remove listener
class _MyWidgetState extends State<MyWidget> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {}

  @override
  Widget build(BuildContext context) => Container();
}
```

#### Example: dispose_notifier

```dart
// NOT RECOMMENDED - Controller never disposed (memory leak)
class _MyWidgetState extends State<MyWidget> {
  final _controller = TextEditingController(); // ERROR!

  @override
  Widget build(BuildContext context) => TextField(controller: _controller);
}

// RECOMMENDED - Properly dispose controller
class _MyWidgetState extends State<MyWidget> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => TextField(controller: _controller);
}
```

---

## Complete Rules List

| # | Rule Name | Category | Target |
|---|-----------|----------|--------|
| 1 | `presentation_layer_isolation` | Architecture | screens/, widgets/ |
| 2 | `shared_widget_purity` | Architecture | widgets/ |
| 3 | `model_purity` | Architecture | models/ |
| 4 | `repository_isolation` | Architecture | repositories/ |
| 5 | `provider_autodispose_enforcement` | Riverpod | providers/ |
| 6 | `provider_file_naming` | Riverpod | providers/ |
| 7 | `provider_state_class` | Riverpod | providers/ |
| 8 | `provider_declaration_syntax` | Riverpod | providers/ |
| 9 | `provider_class_restriction` | Riverpod | providers/ |
| 10 | `provider_single_per_file` | Riverpod | providers/ |
| 11 | `viewmodel_naming_convention` | Riverpod | providers/ |
| 12 | `no_context_in_providers` | Riverpod | providers/ |
| 13 | `async_viewmodel_safety` | Riverpod | providers/ |
| 14 | `repository_provider_declaration` | Repository | repositories/ |
| 15 | `repository_dependency_injection` | Repository | repositories/ |
| 16 | `repository_class_restriction` | Repository | repositories/ |
| 17 | `repository_no_try_catch` | Repository | repositories/ |
| 18 | `repository_async_return` | Repository | repositories/ |
| 19 | `complexity_limits` | Code Quality | lib/ |
| 20 | `global_variable_restriction` | Code Quality | lib/ |
| 21 | `print_ban` | Code Quality | lib/ |
| 22 | `barrel_file_restriction` | Code Quality | lib/ |
| 23 | `ignore_file_ban` | Code Quality | lib/ |
| 24 | `hook_safety_enforcement` | UI Safety | build() methods |
| 25 | `scaffold_location` | UI Safety | widgets/ |
| 26 | `asset_safety` | UI Safety | All files |
| 27 | `file_class_match` | UI Safety | All files |
| 28 | `avoid_consecutive_sliver_to_box_adapter` | Flutter Best Practices | All files |
| 29 | `avoid_hardcoded_color` | Flutter Best Practices | All files |
| 30 | `avoid_shrink_wrap_in_list_view` | Flutter Best Practices | All files |
| 31 | `avoid_single_child` | Flutter Best Practices | All files |
| 32 | `prefer_dedicated_media_query_methods` | Flutter Best Practices | All files |
| 33 | `prefer_space_between_elements` | Flutter Best Practices | All files |
| 34 | `prefer_to_include_sliver_in_name` | Flutter Best Practices | All files |
| 35 | `unsafe_null_assertion` | Flutter Best Practices | All files |
| 36 | `avoid_unnecessary_padding_widget` | Flutter Best Practices | All files |
| 37 | `unnecessary_hook_widget` | Flutter Best Practices | All files |
| 38 | `remove_listener` | Resource Management | State classes |
| 39 | `dispose_notifier` | Resource Management | State classes |
| 40 | `unnecessary_container` | Flutter Best Practices | All files |

---

## Project Structure

For `arsync_lints` to work correctly, organize your project like this:

```
lib/
├── main.dart
├── screens/              # UI pages (can use Scaffold)
│   ├── home/
│   │   └── home_screen.dart
│   └── auth/
│       └── login_screen.dart
├── widgets/              # Reusable UI components (no Scaffold, no providers)
│   ├── buttons/
│   │   └── primary_button.dart
│   └── cards/
│       └── user_card.dart
├── providers/            # State management (Riverpod Notifiers)
│   ├── core/             # Infrastructure providers (dioProvider, etc.)
│   │   └── dio_provider.dart
│   ├── auth_provider.dart
│   └── user_provider.dart
├── models/               # Data classes (Freezed)
│   ├── user.dart
│   └── auth_state.dart
├── repositories/         # Data access layer
│   ├── auth_repository.dart
│   └── user_repository.dart
└── utils/
    ├── constants.dart    # k-prefixed constants and functions
    └── images.dart       # Asset path constants
```

## Suppressing Rules

While `// ignore_for_file:` is banned, you can still use line-specific ignores for rare exceptions:

```dart
// ignore: print_ban
print('Debug only - remove before commit');
```

## CI/CD Integration

Add to your CI pipeline to enforce architecture:

```yaml
# GitHub Actions example
- name: Run Analysis
  run: dart analyze --fatal-infos --fatal-warnings
```

## Philosophy

> "Architecture is about intent. These rules make your intent explicit and your boundaries clear."

The Arsync architecture is designed to:

1. **Prevent spaghetti code** - Clear boundaries between layers
2. **Enable testability** - Each layer can be tested in isolation
3. **Improve maintainability** - New developers understand the structure immediately
4. **Catch issues early** - Violations are build errors, not runtime surprises

## Contributing

Contributions are welcome! Please feel free to submit issues and pull requests.

## License

MIT License - see [LICENSE](LICENSE) for details.
