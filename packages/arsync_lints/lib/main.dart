/// Entry point for the arsync_lints analyzer plugin.
///
/// The [plugin] variable is discovered automatically by the Dart Analysis Server.
/// This is the modern plugin architecture introduced in Dart 3.10.
///
/// See: https://dart.dev/tools/analyzer-plugins
library;

import 'arsync_plugin.dart';

/// The plugin instance that the Dart Analysis Server will use.
///
/// This top-level variable is required by the analysis_server_plugin system.
/// The Analysis Server imports this file and references this variable when
/// loading the plugin.
final plugin = ArsyncPlugin();
