/// The main plugin class for arsync_lints.
///
/// This plugin enforces the Arsync 4-Layer Architecture with strict
/// separation of concerns, Riverpod best practices, and clean code standards.
library;

import 'package:analysis_server_plugin/plugin.dart';
import 'package:analysis_server_plugin/registry.dart';

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
import 'src/rules/early_return_enforcement.dart';
import 'src/rules/global_variable_restriction.dart';
import 'src/rules/print_ban.dart';
import 'src/rules/barrel_file_restriction.dart';
import 'src/rules/ignore_file_ban.dart';

// Category E: UI Safety & Consistency
import 'src/rules/hook_safety_enforcement.dart';
import 'src/rules/scaffold_location.dart';
import 'src/rules/asset_safety.dart';
import 'src/rules/file_class_match.dart';

// Quick Fixes - Category A
import 'src/fixes/presentation_layer_isolation_fix.dart';
import 'src/fixes/shared_widget_purity_fix.dart';
import 'src/fixes/model_purity_fix.dart';
import 'src/fixes/repository_isolation_fix.dart';

// Quick Fixes - Category B
import 'src/fixes/async_viewmodel_safety_fix.dart';
import 'src/fixes/no_context_in_providers_fix.dart';
import 'src/fixes/provider_autodispose_enforcement_fix.dart';
import 'src/fixes/provider_class_restriction_fix.dart';
import 'src/fixes/provider_declaration_syntax_fix.dart';
import 'src/fixes/provider_file_naming_fix.dart';
import 'src/fixes/provider_single_per_file_fix.dart';
import 'src/fixes/provider_state_class_fix.dart';
import 'src/fixes/viewmodel_naming_convention_fix.dart';

// Quick Fixes - Category C
import 'src/fixes/repository_async_return_fix.dart';
import 'src/fixes/repository_class_restriction_fix.dart';
import 'src/fixes/repository_dependency_injection_fix.dart';
import 'src/fixes/repository_no_try_catch_fix.dart';
import 'src/fixes/repository_provider_declaration_fix.dart';

// Quick Fixes - Category D
import 'src/fixes/barrel_file_restriction_fix.dart';
import 'src/fixes/complexity_limits_fix.dart';
import 'src/fixes/early_return_enforcement_fix.dart';
import 'src/fixes/global_variable_restriction_fix.dart';
import 'src/fixes/ignore_file_ban_fix.dart';
import 'src/fixes/print_ban_fix.dart';

// Quick Fixes - Category E
import 'src/fixes/asset_safety_fix.dart';
import 'src/fixes/file_class_match_fix.dart';
import 'src/fixes/hook_safety_enforcement_fix.dart';
import 'src/fixes/scaffold_location_fix.dart';

/// The main arsync_lints plugin class.
///
/// This class extends [Plugin] from the analysis_server_plugin package
/// and registers all lint rules in the [register] method.
///
/// Rules are categorized as:
/// - **Category A**: Architectural Layer Isolation
/// - **Category B**: Riverpod & State Management
/// - **Category C**: Repository & Data Integrity
/// - **Category D**: Code Quality & Complexity
/// - **Category E**: UI Safety & Consistency
class ArsyncPlugin extends Plugin {
  /// The display name of this plugin.
  @override
  String get name => 'arsync_lints';

  /// Registers all lint rules with the plugin registry.
  ///
  /// Use [PluginRegistry.registerWarningRule] for rules that should be
  /// enabled by default (like standard analyzer warnings).
  ///
  /// Use [PluginRegistry.registerLintRule] for rules that are disabled
  /// by default and must be explicitly enabled in analysis_options.yaml.
  @override
  void register(PluginRegistry registry) {
    // Category A: Architectural Layer Isolation
    // These rules prevent cross-layer imports and enforce strict boundaries.
    registry.registerWarningRule(PresentationLayerIsolation());
    registry.registerWarningRule(SharedWidgetPurity());
    registry.registerWarningRule(ModelPurity());
    registry.registerWarningRule(RepositoryIsolation());

    // Category B: Riverpod & State Management
    // These rules enforce Riverpod best practices and provider patterns.
    registry.registerWarningRule(ProviderAutodisposeEnforcement());
    registry.registerWarningRule(ViewModelNamingConvention());
    registry.registerWarningRule(NoContextInProviders());
    registry.registerWarningRule(AsyncViewModelSafety());
    registry.registerWarningRule(ProviderFileNaming());
    registry.registerWarningRule(ProviderStateClass());
    registry.registerWarningRule(ProviderDeclarationSyntax());
    registry.registerWarningRule(ProviderClassRestriction());
    registry.registerWarningRule(ProviderSinglePerFile());

    // Category C: Repository & Data Integrity
    // These rules enforce repository conventions and data access patterns.
    registry.registerWarningRule(RepositoryNoTryCatch());
    registry.registerWarningRule(RepositoryAsyncReturn());
    registry.registerWarningRule(RepositoryProviderDeclaration());
    registry.registerWarningRule(RepositoryDependencyInjection());
    registry.registerWarningRule(RepositoryClassRestriction());

    // Category D: Code Quality & Complexity
    // These rules enforce clean code standards and complexity limits.
    registry.registerWarningRule(ComplexityLimits());
    registry.registerWarningRule(EarlyReturnEnforcement());
    registry.registerWarningRule(GlobalVariableRestriction());
    registry.registerWarningRule(PrintBan());
    registry.registerWarningRule(BarrelFileRestriction());
    registry.registerWarningRule(IgnoreFileBan());

    // Category E: UI Safety & Consistency
    // These rules enforce widget and hook patterns.
    registry.registerWarningRule(HookSafetyEnforcement());
    registry.registerWarningRule(ScaffoldLocation());
    registry.registerWarningRule(AssetSafety());
    registry.registerWarningRule(FileClassMatch());

    // Quick Fixes
    // Register fixes for rules that have automated corrections.

    // Category B: Riverpod fixes
    registry.registerFixForRule(
      ProviderAutodisposeEnforcement.code,
      ProviderAutodisposeEnforcementFix.new,
    );
    registry.registerFixForRule(
      ViewModelNamingConvention.classCode,
      ViewModelClassNamingFix.new,
    );
    registry.registerFixForRule(
      ViewModelNamingConvention.providerCode,
      ViewModelProviderNamingFix.new,
    );
    registry.registerFixForRule(
      AsyncViewModelSafety.code,
      AsyncViewModelSafetyFix.new,
    );
    registry.registerFixForRule(
      ProviderDeclarationSyntax.code,
      ProviderDeclarationSyntaxFix.new,
    );

    // Category D: Code Quality fixes
    registry.registerFixForRule(
      GlobalVariableRestriction.variableCode,
      GlobalVariableRestrictionFix.new,
    );
    registry.registerFixForRule(
      GlobalVariableRestriction.functionCode,
      GlobalVariableRestrictionFix.new,
    );
    registry.registerFixForRule(
      PrintBan.code,
      PrintBanFix.new,
    );
    registry.registerFixForRule(
      IgnoreFileBan.code,
      IgnoreFileBanFix.new,
    );

    // Category E: UI Safety fixes
    registry.registerFixForRule(
      HookSafetyEnforcement.controllerCode,
      HookSafetyControllerFix.new,
    );
    registry.registerFixForRule(
      HookSafetyEnforcement.formKeyCode,
      HookSafetyFormKeyFix.new,
    );
    registry.registerFixForRule(
      ScaffoldLocation.code,
      ScaffoldLocationFix.new,
    );
    registry.registerFixForRule(
      FileClassMatch.code,
      FileClassMatchFix.new,
    );

    // Category A: Architectural Layer Isolation fixes
    registry.registerFixForRule(
      PresentationLayerIsolation.importCode,
      PresentationLayerIsolationImportFix.new,
    );
    registry.registerFixForRule(
      PresentationLayerIsolation.useRecordCode,
      PresentationLayerUseRecordFix.new,
    );
    registry.registerFixForRule(
      SharedWidgetPurity.importCode,
      SharedWidgetPurityImportFix.new,
    );
    registry.registerFixForRule(
      SharedWidgetPurity.singleWidgetCode,
      SharedWidgetPurityMakePrivateFix.new,
    );
    registry.registerFixForRule(
      ModelPurity.importCode,
      ModelPurityImportFix.new,
    );
    registry.registerFixForRule(
      ModelPurity.freezedCode,
      ModelPurityAddFreezedFix.new,
    );
    registry.registerFixForRule(
      ModelPurity.fromJsonCode,
      ModelPurityAddFromJsonFix.new,
    );
    registry.registerFixForRule(
      RepositoryIsolation.code,
      RepositoryIsolationFix.new,
    );

    // Category B: More Riverpod fixes
    registry.registerFixForRule(
      NoContextInProviders.code,
      NoContextInProvidersFix.new,
    );
    registry.registerFixForRule(
      ProviderFileNaming.fileCode,
      ProviderFileNamingFix.new,
    );
    registry.registerFixForRule(
      ProviderFileNaming.notifierMissingCode,
      ProviderFileNamingFix.new,
    );
    registry.registerFixForRule(
      ProviderStateClass.freezedCode,
      ProviderStateClassAddFreezedFix.new,
    );
    registry.registerFixForRule(
      ProviderStateClass.importedStateCode,
      ProviderStateClassMoveHereFix.new,
    );
    registry.registerFixForRule(
      ProviderClassRestriction.code,
      ProviderClassRestrictionMakePrivateFix.new,
    );
    registry.registerFixForRule(
      ProviderSinglePerFile.multipleProvidersCode,
      ProviderSinglePerFileRenameFix.new,
    );
    registry.registerFixForRule(
      ProviderSinglePerFile.nameMismatchCode,
      ProviderSinglePerFileRenameFix.new,
    );

    // Category C: Repository fixes
    registry.registerFixForRule(
      RepositoryNoTryCatch.code,
      RepositoryNoTryCatchFix.new,
    );
    registry.registerFixForRule(
      RepositoryAsyncReturn.code,
      RepositoryAsyncReturnFix.new,
    );
    registry.registerFixForRule(
      RepositoryClassRestriction.classCode,
      RepositoryClassRestrictionAddSuffixFix.new,
    );
    registry.registerFixForRule(
      RepositoryClassRestriction.classCode,
      RepositoryClassRestrictionMakePrivateFix.new,
    );
    registry.registerFixForRule(
      RepositoryClassRestriction.fileNameCode,
      RepositoryClassRestrictionAddSuffixFix.new,
    );
    registry.registerFixForRule(
      RepositoryProviderDeclaration.wrongNamingCode,
      RepositoryProviderDeclarationRenameFix.new,
    );
    registry.registerFixForRule(
      RepositoryProviderDeclaration.missingProviderCode,
      RepositoryProviderDeclarationAddFix.new,
    );
    registry.registerFixForRule(
      RepositoryDependencyInjection.directInstantiationCode,
      RepositoryDependencyInjectionFix.new,
    );
    registry.registerFixForRule(
      RepositoryDependencyInjection.refNotAllowedCode,
      RepositoryDependencyInjectionRemoveRefFix.new,
    );

    // Category D: More Code Quality fixes
    registry.registerFixForRule(
      ComplexityLimits.nestedTernaryCode,
      ComplexityLimitsAddTodoFix.new,
    );
    registry.registerFixForRule(
      ComplexityLimits.paramCode,
      ComplexityLimitsAddTodoFix.new,
    );
    registry.registerFixForRule(
      ComplexityLimits.nestingCode,
      ComplexityLimitsAddTodoFix.new,
    );
    registry.registerFixForRule(
      ComplexityLimits.methodLinesCode,
      ComplexityLimitsAddTodoFix.new,
    );
    registry.registerFixForRule(
      ComplexityLimits.buildLinesCode,
      ComplexityLimitsAddTodoFix.new,
    );
    registry.registerFixForRule(
      BarrelFileRestriction.code,
      BarrelFileRestrictionFix.new,
    );
    registry.registerFixForRule(
      EarlyReturnEnforcement.code,
      EarlyReturnEnforcementFix.new,
    );

    // Category E: More UI Safety fixes
    registry.registerFixForRule(
      AssetSafety.code,
      AssetSafetyFix.new,
    );
  }
}
