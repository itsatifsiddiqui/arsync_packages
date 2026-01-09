/// arsync_lints - A custom lint package for Flutter/Dart that enforces
/// the Arsync 4-layer architecture with strict separation of concerns,
/// Riverpod best practices, and clean code standards.
library;

import 'package:custom_lint_builder/custom_lint_builder.dart';

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

/// This is the entrypoint of the custom linter.
PluginBase createPlugin() => _ArsyncLintsPlugin();

/// The main plugin class that registers all lint rules.
class _ArsyncLintsPlugin extends PluginBase {
  @override
  List<LintRule> getLintRules(CustomLintConfigs configs) => [
        // Category A: Architectural Layer Isolation
        const PresentationLayerIsolation(),
        const SharedWidgetPurity(),
        const ModelPurity(),
        const RepositoryIsolation(),

        // Category B: Riverpod & State Management
        const ProviderAutodisposeEnforcement(),
        const ViewModelNamingConvention(),
        const NoContextInProviders(),
        const AsyncViewModelSafety(),
        const ProviderFileNaming(),
        const ProviderStateClass(),
        const ProviderDeclarationSyntax(),
        const ProviderClassRestriction(),
        const ProviderSinglePerFile(),

        // Category C: Repository & Data Integrity
        const RepositoryNoTryCatch(),
        const RepositoryAsyncReturn(),
        const RepositoryProviderDeclaration(),
        const RepositoryDependencyInjection(),
        const RepositoryClassRestriction(),

        // Category D: Code Quality & Complexity
        const ComplexityLimits(),
        const GlobalVariableRestriction(),
        const PrintBan(),
        const BarrelFileRestriction(),
        const IgnoreFileBan(),

        // Category E: UI Safety & Consistency
        const HookSafetyEnforcement(),
        const ScaffoldLocation(),
        const AssetSafety(),
        const FileClassMatch(),
      ];
}
