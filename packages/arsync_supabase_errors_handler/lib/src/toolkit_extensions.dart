import 'package:arsync_exception_toolkit/arsync_exception_toolkit.dart';

import './supabase_auth_handler.dart';
import './supabase_database_handler.dart';
import './supabase_storage_handler.dart';
import './supabase_functions_handler.dart';
import './supabase_realtime_handler.dart';
import 'supabase_errors_handler.dart';

/// Extension methods for ArsyncExceptionToolkit to work with Supabase handlers
extension SupabaseToolkitExtensions on ArsyncExceptionToolkit {
  /// Add a Supabase Auth handler to the toolkit
  ///
  /// [customExceptions] - Optional custom error exceptions for the handler
  /// [priority] - Optional priority for the handler
  ///
  /// Returns the toolkit instance for chaining
  ArsyncExceptionToolkit withSupabaseAuthHandler({
    Map<String, ArsyncException>? customExceptions,
    int priority = 20,
  }) {
    exceptionMapper.handlers.add(
      SupabaseAuthHandler(
        customExceptions: customExceptions,
        priority: priority,
      ),
    );
    return this;
  }

  /// Add a Supabase Database handler to the toolkit
  ///
  /// [customExceptions] - Optional custom error exceptions for the handler
  /// [priority] - Optional priority for the handler
  ///
  /// Returns the toolkit instance for chaining
  ArsyncExceptionToolkit withSupabaseDatabaseHandler({
    Map<String, ArsyncException>? customExceptions,
    int priority = 18,
  }) {
    exceptionMapper.handlers.add(
      SupabaseDatabaseHandler(
        customExceptions: customExceptions,
        priority: priority,
      ),
    );
    return this;
  }

  /// Add a Supabase Storage handler to the toolkit
  ///
  /// [customExceptions] - Optional custom error exceptions for the handler
  /// [priority] - Optional priority for the handler
  ///
  /// Returns the toolkit instance for chaining
  ArsyncExceptionToolkit withSupabaseStorageHandler({
    Map<String, ArsyncException>? customExceptions,
    int priority = 16,
  }) {
    exceptionMapper.handlers.add(
      SupabaseStorageHandler(
        customExceptions: customExceptions,
        priority: priority,
      ),
    );
    return this;
  }

  /// Add a Supabase Functions handler to the toolkit
  ///
  /// [customExceptions] - Optional custom error exceptions for the handler
  /// [priority] - Optional priority for the handler
  ///
  /// Returns the toolkit instance for chaining
  ArsyncExceptionToolkit withSupabaseFunctionsHandler({
    Map<String, ArsyncException>? customExceptions,
    int priority = 17,
  }) {
    exceptionMapper.handlers.add(
      SupabaseFunctionsHandler(
        customExceptions: customExceptions,
        priority: priority,
      ),
    );
    return this;
  }

  /// Add a Supabase Realtime handler to the toolkit
  ///
  /// [customExceptions] - Optional custom error exceptions for the handler
  /// [priority] - Optional priority for the handler
  ///
  /// Returns the toolkit instance for chaining
  ArsyncExceptionToolkit withSupabaseRealtimeHandler({
    Map<String, ArsyncException>? customExceptions,
    int priority = 15,
  }) {
    exceptionMapper.handlers.add(
      SupabaseRealtimeHandler(
        customExceptions: customExceptions,
        priority: priority,
      ),
    );
    return this;
  }

  /// Add all Supabase handlers to the toolkit
  ///
  /// [authHandler] - Optional custom Supabase Auth handler
  /// [databaseHandler] - Optional custom Database handler
  /// [storageHandler] - Optional custom Storage handler
  /// [functionsHandler] - Optional custom Functions handler
  /// [realtimeHandler] - Optional custom Realtime handler
  /// [priority] - Optional priority for the combined handler
  ///
  /// Returns the toolkit instance for chaining
  ArsyncExceptionToolkit withAllSupabaseHandlers({
    SupabaseAuthHandler? authHandler,
    SupabaseDatabaseHandler? databaseHandler,
    SupabaseStorageHandler? storageHandler,
    SupabaseFunctionsHandler? functionsHandler,
    SupabaseRealtimeHandler? realtimeHandler,
    int priority = 25,
  }) {
    exceptionMapper.handlers.add(
      SupabaseErrorsHandler(
        authHandler: authHandler,
        databaseHandler: databaseHandler,
        storageHandler: storageHandler,
        functionsHandler: functionsHandler,
        realtimeHandler: realtimeHandler,
        priority: priority,
      ),
    );
    return this;
  }
}

/// Extension methods for ArsyncExceptionMapper to work with Supabase handlers
extension SupabaseMapperExtensions on List<ArsyncExceptionHandler> {
  /// Add a Supabase Auth handler to the mapper
  ///
  /// [customExceptions] - Optional custom error exceptions for the handler
  /// [priority] - Optional priority for the handler
  void addSupabaseAuthHandler({
    Map<String, ArsyncException>? customExceptions,
    int priority = 20,
  }) {
    add(
      SupabaseAuthHandler(
        customExceptions: customExceptions,
        priority: priority,
      ),
    );
  }

  /// Add a Supabase Database handler to the mapper
  ///
  /// [customExceptions] - Optional custom error exceptions for the handler
  /// [priority] - Optional priority for the handler
  void addSupabaseDatabaseHandler({
    Map<String, ArsyncException>? customExceptions,
    int priority = 18,
  }) {
    add(
      SupabaseDatabaseHandler(
        customExceptions: customExceptions,
        priority: priority,
      ),
    );
  }

  /// Add a Supabase Storage handler to the mapper
  ///
  /// [customExceptions] - Optional custom error exceptions for the handler
  /// [priority] - Optional priority for the handler
  void addSupabaseStorageHandler({
    Map<String, ArsyncException>? customExceptions,
    int priority = 16,
  }) {
    add(
      SupabaseStorageHandler(
        customExceptions: customExceptions,
        priority: priority,
      ),
    );
  }

  /// Add a Supabase Functions handler to the mapper
  ///
  /// [customExceptions] - Optional custom error exceptions for the handler
  /// [priority] - Optional priority for the handler
  void addSupabaseFunctionsHandler({
    Map<String, ArsyncException>? customExceptions,
    int priority = 17,
  }) {
    add(
      SupabaseFunctionsHandler(
        customExceptions: customExceptions,
        priority: priority,
      ),
    );
  }

  /// Add a Supabase Realtime handler to the mapper
  ///
  /// [customExceptions] - Optional custom error exceptions for the handler
  /// [priority] - Optional priority for the handler
  void addSupabaseRealtimeHandler({
    Map<String, ArsyncException>? customExceptions,
    int priority = 15,
  }) {
    add(
      SupabaseRealtimeHandler(
        customExceptions: customExceptions,
        priority: priority,
      ),
    );
  }

  /// Add all Supabase handlers to the mapper
  ///
  /// [authHandler] - Optional custom Supabase Auth handler
  /// [databaseHandler] - Optional custom Database handler
  /// [storageHandler] - Optional custom Storage handler
  /// [functionsHandler] - Optional custom Functions handler
  /// [realtimeHandler] - Optional custom Realtime handler
  /// [priority] - Optional priority for the combined handler
  void addAllSupabaseHandlers({
    SupabaseAuthHandler? authHandler,
    SupabaseDatabaseHandler? databaseHandler,
    SupabaseStorageHandler? storageHandler,
    SupabaseFunctionsHandler? functionsHandler,
    SupabaseRealtimeHandler? realtimeHandler,
    int priority = 25,
  }) {
    add(
      SupabaseErrorsHandler(
        authHandler: authHandler,
        databaseHandler: databaseHandler,
        storageHandler: storageHandler,
        functionsHandler: functionsHandler,
        realtimeHandler: realtimeHandler,
        priority: priority,
      ),
    );
  }
}