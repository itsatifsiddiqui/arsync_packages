/// arsync_lints - A lint package for Flutter/Dart that enforces
/// the Arsync 4-layer architecture with strict separation of concerns,
/// Riverpod best practices, and clean code standards.
///
/// This package uses the native analysis_server_plugin system (Dart 3.10+).
/// The plugin is automatically discovered via `lib/main.dart`.
///
/// To use this linter, add arsync_lints to your dev_dependencies
/// and include it in your analysis_options.yaml:
///
/// ```yaml
/// # Dart 3.10+ native plugin system - plugins is a TOP-LEVEL section
/// plugins:
///   arsync_lints:
/// ```
library;

// Export the plugin for programmatic access
export 'arsync_plugin.dart' show ArsyncPlugin;
