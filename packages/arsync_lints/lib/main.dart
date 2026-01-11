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

// Category G: Resource Management
import 'src/rules/remove_listener.dart';
import 'src/rules/dispose_notifier.dart';

// Category F: Flutter Best Practices
import 'src/rules/avoid_consecutive_sliver_to_box_adapter.dart';
import 'src/rules/avoid_hardcoded_color.dart';
import 'src/rules/avoid_shrink_wrap_in_list_view.dart';
import 'src/rules/avoid_single_child.dart';
import 'src/rules/prefer_dedicated_media_query_methods.dart';
import 'src/rules/prefer_space_between_elements.dart';
import 'src/rules/prefer_to_include_sliver_in_name.dart';
import 'src/rules/unsafe_null_assertion.dart';
import 'src/rules/avoid_unnecessary_padding_widget.dart';
import 'src/rules/unnecessary_hook_widget.dart';
import 'src/rules/unnecessary_container.dart';

// Fixes - Category A
import 'src/fixes/presentation_layer_isolation_fix.dart';
import 'src/fixes/shared_widget_purity_fix.dart';
import 'src/fixes/model_purity_fix.dart';
import 'src/fixes/repository_isolation_fix.dart';

// Fixes - Category B
import 'src/fixes/provider_autodispose_enforcement_fix.dart';
import 'src/fixes/viewmodel_naming_convention_fix.dart';
import 'src/fixes/no_context_in_providers_fix.dart';
import 'src/fixes/async_viewmodel_safety_fix.dart';
import 'src/fixes/provider_file_naming_fix.dart';
import 'src/fixes/provider_state_class_fix.dart';
import 'src/fixes/provider_declaration_syntax_fix.dart';
import 'src/fixes/provider_class_restriction_fix.dart';
import 'src/fixes/provider_single_per_file_fix.dart';

// Fixes - Category C
import 'src/fixes/repository_no_try_catch_fix.dart';
import 'src/fixes/repository_async_return_fix.dart';
import 'src/fixes/repository_provider_declaration_fix.dart';
import 'src/fixes/repository_dependency_injection_fix.dart';
import 'src/fixes/repository_class_restriction_fix.dart';

// Fixes - Category D
import 'src/fixes/complexity_limits_fix.dart';
import 'src/fixes/global_variable_restriction_fix.dart';
import 'src/fixes/print_ban_fix.dart';
import 'src/fixes/barrel_file_restriction_fix.dart';
import 'src/fixes/ignore_file_ban_fix.dart';

// Fixes - Category E
import 'src/fixes/hook_safety_enforcement_fix.dart';
import 'src/fixes/scaffold_location_fix.dart';
import 'src/fixes/asset_safety_fix.dart';
import 'src/fixes/file_class_match_fix.dart';

// Fixes - Category G
import 'src/fixes/remove_listener_fix.dart';
import 'src/fixes/dispose_notifier_fix.dart';

// Fixes - Category F
import 'src/fixes/avoid_consecutive_sliver_to_box_adapter_fix.dart';
import 'src/fixes/avoid_hardcoded_color_fix.dart';
import 'src/fixes/avoid_shrink_wrap_in_list_view_fix.dart';
import 'src/fixes/avoid_single_child_fix.dart';
import 'src/fixes/prefer_dedicated_media_query_methods_fix.dart';
import 'src/fixes/prefer_space_between_elements_fix.dart';
import 'src/fixes/prefer_to_include_sliver_in_name_fix.dart';
import 'src/fixes/unsafe_null_assertion_fix.dart';
import 'src/fixes/avoid_unnecessary_padding_widget_fix.dart';
import 'src/fixes/unnecessary_hook_widget_fix.dart';
import 'src/fixes/unnecessary_container_fix.dart';

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
      // Category G: Resource Management
      RemoveListener(),
      DisposeNotifier(),
      // Category F: Flutter Best Practices
      AvoidConsecutiveSliverToBoxAdapter(),
      AvoidHardcodedColor(),
      AvoidShrinkWrapInListView(),
      AvoidSingleChild(),
      PreferDedicatedMediaQueryMethods(),
      PreferSpaceBetweenElements(),
      PreferToIncludeSliverInName(),
      UnsafeNullAssertion(),
      AvoidUnnecessaryPaddingWidget(),
      UnnecessaryHookWidget(),
      UnnecessaryContainer(),
    ].forEach(registry.registerWarningRule);

    // Register fixes for Category A: Architectural Layer Isolation
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

    // Register fixes for Category B: Riverpod & State Management
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
      NoContextInProviders.code,
      NoContextInProvidersFix.new,
    );
    registry.registerFixForRule(
      AsyncViewModelSafety.code,
      AsyncViewModelSafetyFix.new,
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
      ProviderDeclarationSyntax.code,
      ProviderDeclarationSyntaxFix.new,
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

    // Register fixes for Category C: Repository & Data Integrity
    registry.registerFixForRule(
      RepositoryNoTryCatch.code,
      RepositoryNoTryCatchFix.new,
    );
    registry.registerFixForRule(
      RepositoryAsyncReturn.code,
      RepositoryAsyncReturnFix.new,
    );
    registry.registerFixForRule(
      RepositoryProviderDeclaration.missingProviderCode,
      RepositoryProviderDeclarationAddFix.new,
    );
    registry.registerFixForRule(
      RepositoryProviderDeclaration.wrongNamingCode,
      RepositoryProviderDeclarationRenameFix.new,
    );
    registry.registerFixForRule(
      RepositoryDependencyInjection.directInstantiationCode,
      RepositoryDependencyInjectionFix.new,
    );
    registry.registerFixForRule(
      RepositoryDependencyInjection.refNotAllowedCode,
      RepositoryDependencyInjectionFix.new,
    );
    registry.registerFixForRule(
      RepositoryClassRestriction.classCode,
      RepositoryClassRestrictionAddSuffixFix.new,
    );
    registry.registerFixForRule(
      RepositoryClassRestriction.fileNameCode,
      RepositoryClassRestrictionMakePrivateFix.new,
    );

    // Register fixes for Category D: Code Quality & Complexity
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
      ComplexityLimits.nestedTernaryCode,
      ComplexityLimitsAddTodoFix.new,
    );
    registry.registerFixForRule(
      GlobalVariableRestriction.variableCode,
      GlobalVariableRestrictionFix.new,
    );
    registry.registerFixForRule(
      GlobalVariableRestriction.functionCode,
      GlobalVariableRestrictionFix.new,
    );
    registry.registerFixForRule(PrintBan.code, PrintBanFix.new);
    registry.registerFixForRule(
      BarrelFileRestriction.code,
      BarrelFileRestrictionFix.new,
    );
    registry.registerFixForRule(IgnoreFileBan.code, IgnoreFileBanFix.new);

    // Register fixes for Category E: UI Safety & Consistency
    registry.registerFixForRule(
      HookSafetyEnforcement.controllerCode,
      HookSafetyControllerFix.new,
    );
    registry.registerFixForRule(
      HookSafetyEnforcement.formKeyCode,
      HookSafetyFormKeyFix.new,
    );
    registry.registerFixForRule(ScaffoldLocation.code, ScaffoldLocationFix.new);
    registry.registerFixForRule(AssetSafety.code, AssetSafetyFix.new);
    registry.registerFixForRule(FileClassMatch.code, FileClassMatchFix.new);

    // Register fixes for Category G: Resource Management
    registry.registerFixForRule(
      RemoveListener.code,
      AddRemoveListenerCallFix.new,
    );
    registry.registerFixForRule(DisposeNotifier.code, AddDisposeMethodFix.new);
    registry.registerFixForRule(DisposeNotifier.code, AddDisposeCallFix.new);

    // Register fixes for Category F: Flutter Best Practices
    registry.registerFixForRule(
      AvoidConsecutiveSliverToBoxAdapter.code,
      AvoidConsecutiveSliverToBoxAdapterFix.new,
    );
    registry.registerFixForRule(
      AvoidHardcodedColor.code,
      AvoidHardcodedColorFix.new,
    );
    registry.registerFixForRule(
      AvoidShrinkWrapInListView.code,
      AvoidShrinkWrapInListViewFix.new,
    );
    registry.registerFixForRule(AvoidSingleChild.code, AvoidSingleChildFix.new);
    registry.registerFixForRule(
      PreferDedicatedMediaQueryMethods.code,
      PreferDedicatedMediaQueryMethodsFix.new,
    );
    registry.registerFixForRule(
      PreferSpaceBetweenElements.code,
      PreferSpaceBetweenElementsFix.new,
    );
    registry.registerFixForRule(
      PreferToIncludeSliverInName.code,
      PreferToIncludeSliverInNameFix.new,
    );
    registry.registerFixForRule(
      UnsafeNullAssertion.code,
      UnsafeNullAssertionFix.new,
    );
    registry.registerFixForRule(
      AvoidUnnecessaryPaddingWidget.paddingWrapsContainerCode,
      PaddingWrapsContainerFix.new,
    );
    registry.registerFixForRule(
      AvoidUnnecessaryPaddingWidget.containerWrapsPaddingCode,
      ContainerWrapsPaddingFix.new,
    );
    registry.registerFixForRule(
      UnnecessaryHookWidget.code,
      UnnecessaryHookWidgetFix.new,
    );
    registry.registerFixForRule(
      UnnecessaryContainer.code,
      UnnecessaryContainerFix.new,
    );
  }
}
