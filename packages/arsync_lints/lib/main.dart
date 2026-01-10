/// arsync_lints - A lint package for Flutter/Dart that enforces
/// the Arsync 4-layer architecture with strict separation of concerns,
/// Riverpod best practices, and clean code standards.
///
/// This package uses the native analysis_server_plugin system (Dart 3.10+).
/// The [plugin] variable is discovered automatically by the Dart Analysis Server.
///
/// See: https://dart.dev/tools/analyzer-plugins
library;

import 'dart:async';

import 'package:analysis_server_plugin/plugin.dart';
import 'package:analysis_server_plugin/registry.dart';
import 'package:analyzer/analysis_rule/analysis_rule.dart'
    show AbstractAnalysisRule;

// Category A: Architectural Layer Isolation
import 'src/rules/presentation_layer_isolation.dart';
import 'src/rules/shared_widget_purity.dart';
import 'src/rules/model_purity.dart';
import 'src/rules/repository_isolation.dart';

// Category B: Riverpod & State Management
import 'src/rules/provider_autodispose_enforcement.dart';
import 'src/rules/viewmodel_naming_convention.dart';
import 'src/rules/no_context_in_providers.dart';
import 'src/rules/async_viewmodel_safety.dart';
import 'src/rules/provider_file_naming.dart';
import 'src/rules/provider_state_class.dart';
import 'src/rules/provider_declaration_syntax.dart';
import 'src/rules/provider_class_restriction.dart';
import 'src/rules/provider_single_per_file.dart';

// Category C: Repository & Data Integrity
import 'src/rules/repository_no_try_catch.dart';
import 'src/rules/repository_async_return.dart';
import 'src/rules/repository_provider_declaration.dart';
import 'src/rules/repository_dependency_injection.dart';
import 'src/rules/repository_class_restriction.dart';

// Category D: Code Quality & Complexity
import 'src/rules/complexity_limits.dart';
import 'src/rules/global_variable_restriction.dart';
import 'src/rules/print_ban.dart';
import 'src/rules/barrel_file_restriction.dart';
import 'src/rules/ignore_file_ban.dart';

// Category E: UI Safety & Consistency
import 'src/rules/hook_safety_enforcement.dart';
import 'src/rules/scaffold_location.dart';
import 'src/rules/asset_safety.dart';
import 'src/rules/file_class_match.dart';

/// Enables Arsync lints.
final plugin = _Plugin();

class _Plugin extends Plugin {
  @override
  String get name => 'arsync_lints';

  @override
  Future<void> register(PluginRegistry registry) async {
    <AbstractAnalysisRule>[
      // Category A: Architectural Layer Isolation
      PresentationLayerIsolation(),
      SharedWidgetPurity(),
      ModelPurity(),
      RepositoryIsolation(),
      // Category B: Riverpod & State Management
      ProviderAutodisposeEnforcement(),
      ViewModelNamingConvention(),
      NoContextInProviders(),
      AsyncViewModelSafety(),
      ProviderFileNaming(),
      ProviderStateClass(),
      ProviderDeclarationSyntax(),
      ProviderClassRestriction(),
      ProviderSinglePerFile(),
      // Category C: Repository & Data Integrity
      RepositoryNoTryCatch(),
      RepositoryAsyncReturn(),
      RepositoryProviderDeclaration(),
      RepositoryDependencyInjection(),
      RepositoryClassRestriction(),
      // Category D: Code Quality & Complexity
      ComplexityLimits(),
      GlobalVariableRestriction(),
      PrintBan(),
      BarrelFileRestriction(),
      IgnoreFileBan(),
      // Category E: UI Safety & Consistency
      HookSafetyEnforcement(),
      ScaffoldLocation(),
      AssetSafety(),
      FileClassMatch(),
    ].forEach(registry.registerWarningRule);
  }
}
