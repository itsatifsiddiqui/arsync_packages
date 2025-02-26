import 'package:arsync_exception_toolkit/arsync_exception_toolkit.dart';

import 'supabase_auth_handler.dart';
import 'supabase_database_handler.dart';
import 'supabase_storage_handler.dart';
import 'supabase_functions_handler.dart';
import 'supabase_realtime_handler.dart';

/// A combined handler for all Supabase-related exceptions
///
/// This handler delegates to specific Supabase service handlers based on the
/// exception type. Use this for convenient setup when you want to handle
/// all Supabase exceptions in one go.
class SupabaseErrorsHandler implements ArsyncExceptionHandler {
  final SupabaseAuthHandler _authHandler;
  final SupabaseDatabaseHandler _databaseHandler;
  final SupabaseStorageHandler _storageHandler;
  final SupabaseFunctionsHandler _functionsHandler;
  final SupabaseRealtimeHandler _realtimeHandler;

  /// Priority level for this handler (higher means it's tried earlier)
  final int _priority;

  /// Create a combined Supabase errors handler
  ///
  /// [authHandler] - Optional custom Supabase Auth handler
  /// [databaseHandler] - Optional custom Database handler
  /// [storageHandler] - Optional custom Storage handler
  /// [functionsHandler] - Optional custom Functions handler
  /// [realtimeHandler] - Optional custom Realtime handler
  /// [priority] - Priority level for this handler (higher = higher priority)
  SupabaseErrorsHandler({
    SupabaseAuthHandler? authHandler,
    SupabaseDatabaseHandler? databaseHandler,
    SupabaseStorageHandler? storageHandler,
    SupabaseFunctionsHandler? functionsHandler,
    SupabaseRealtimeHandler? realtimeHandler,
    int priority = 25,
  })  : _authHandler = authHandler ?? SupabaseAuthHandler(),
        _databaseHandler = databaseHandler ?? SupabaseDatabaseHandler(),
        _storageHandler = storageHandler ?? SupabaseStorageHandler(),
        _functionsHandler = functionsHandler ?? SupabaseFunctionsHandler(),
        _realtimeHandler = realtimeHandler ?? SupabaseRealtimeHandler(),
        _priority = priority;

  @override
  bool canHandle(Object exception) {
    return _authHandler.canHandle(exception) ||
        _databaseHandler.canHandle(exception) ||
        _storageHandler.canHandle(exception) ||
        _functionsHandler.canHandle(exception) ||
        _realtimeHandler.canHandle(exception);
  }

  @override
  ArsyncException handle(Object exception) {
    if (_authHandler.canHandle(exception)) {
      return _authHandler.handle(exception);
    }

    if (_databaseHandler.canHandle(exception)) {
      return _databaseHandler.handle(exception);
    }

    if (_storageHandler.canHandle(exception)) {
      return _storageHandler.handle(exception);
    }

    if (_functionsHandler.canHandle(exception)) {
      return _functionsHandler.handle(exception);
    }

    if (_realtimeHandler.canHandle(exception)) {
      return _realtimeHandler.handle(exception);
    }

    // This shouldn't happen if canHandle was checked first
    return ArsyncException.generic(
      title: 'Supabase Error',
      message: 'An unexpected Supabase error occurred',
      originalException: exception,
    );
  }

  @override
  int get priority => _priority;

  /// Get the Supabase Auth handler
  SupabaseAuthHandler get authHandler => _authHandler;

  /// Get the Database handler
  SupabaseDatabaseHandler get databaseHandler => _databaseHandler;

  /// Get the Supabase Storage handler
  SupabaseStorageHandler get storageHandler => _storageHandler;

  /// Get the Supabase Functions handler
  SupabaseFunctionsHandler get functionsHandler => _functionsHandler;

  /// Get the Supabase Realtime handler
  SupabaseRealtimeHandler get realtimeHandler => _realtimeHandler;

  /// Create a new instance with customized handlers
  SupabaseErrorsHandler copyWith({
    SupabaseAuthHandler? authHandler,
    SupabaseDatabaseHandler? databaseHandler,
    SupabaseStorageHandler? storageHandler,
    SupabaseFunctionsHandler? functionsHandler,
    SupabaseRealtimeHandler? realtimeHandler,
    int? priority,
  }) {
    return SupabaseErrorsHandler(
      authHandler: authHandler ?? _authHandler,
      databaseHandler: databaseHandler ?? _databaseHandler,
      storageHandler: storageHandler ?? _storageHandler,
      functionsHandler: functionsHandler ?? _functionsHandler,
      realtimeHandler: realtimeHandler ?? _realtimeHandler,
      priority: priority ?? _priority,
    );
  }
}
