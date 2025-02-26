import 'package:arsync_exception_toolkit/arsync_exception_toolkit.dart';

import 'firebase_auth_handler.dart';
import 'firestore_handler.dart';
import 'functions_handler.dart';
import 'storage_handler.dart';
import 'firebase_core_handler.dart';

/// A combined handler for all Firebase-related exceptions
///
/// This handler delegates to specific Firebase service handlers based on the
/// exception type. Use this for convenient setup when you want to handle
/// all Firebase exceptions in one go.
class FirebaseErrorsHandler implements ArsyncExceptionHandler {
  final FirebaseAuthHandler _authHandler;
  final FirestoreHandler _firestoreHandler;
  final FirebaseFunctionsHandler _functionsHandler;
  final FirebaseStorageHandler _storageHandler;
  final FirebaseCoreHandler _coreHandler;

  /// Priority level for this handler (higher means it's tried earlier)
  final int _priority;

  /// Create a combined Firebase errors handler
  ///
  /// [authHandler] - Optional custom Firebase Auth handler
  /// [firestoreHandler] - Optional custom Firestore handler
  /// [functionsHandler] - Optional custom Functions handler
  /// [storageHandler] - Optional custom Storage handler
  /// [coreHandler] - Optional custom Core handler
  /// [priority] - Priority level for this handler (higher = higher priority)
  FirebaseErrorsHandler({
    FirebaseAuthHandler? authHandler,
    FirestoreHandler? firestoreHandler,
    FirebaseFunctionsHandler? functionsHandler,
    FirebaseStorageHandler? storageHandler,
    FirebaseCoreHandler? coreHandler,
    int priority = 25,
  })  : _authHandler = authHandler ?? FirebaseAuthHandler(),
        _firestoreHandler = firestoreHandler ?? FirestoreHandler(),
        _functionsHandler = functionsHandler ?? FirebaseFunctionsHandler(),
        _storageHandler = storageHandler ?? FirebaseStorageHandler(),
        _coreHandler = coreHandler ?? FirebaseCoreHandler(),
        _priority = priority;

  @override
  bool canHandle(Object exception) {
    return _authHandler.canHandle(exception) ||
        _firestoreHandler.canHandle(exception) ||
        _functionsHandler.canHandle(exception) ||
        _storageHandler.canHandle(exception) ||
        _coreHandler.canHandle(exception);
  }

  @override
  ArsyncException handle(Object exception) {
    if (_authHandler.canHandle(exception)) {
      return _authHandler.handle(exception);
    }

    if (_firestoreHandler.canHandle(exception)) {
      return _firestoreHandler.handle(exception);
    }

    if (_functionsHandler.canHandle(exception)) {
      return _functionsHandler.handle(exception);
    }

    if (_storageHandler.canHandle(exception)) {
      return _storageHandler.handle(exception);
    }

    if (_coreHandler.canHandle(exception)) {
      return _coreHandler.handle(exception);
    }

    // This shouldn't happen if canHandle was checked first
    return ArsyncException.generic(
      title: 'Firebase Error',
      message: 'An unexpected Firebase error occurred',
      originalException: exception,
    );
  }

  @override
  int get priority => _priority;

  /// Get the Firebase Auth handler
  FirebaseAuthHandler get authHandler => _authHandler;

  /// Get the Firestore handler
  FirestoreHandler get firestoreHandler => _firestoreHandler;

  /// Get the Firebase Functions handler
  FirebaseFunctionsHandler get functionsHandler => _functionsHandler;

  /// Get the Firebase Storage handler
  FirebaseStorageHandler get storageHandler => _storageHandler;

  /// Get the Firebase Core handler
  FirebaseCoreHandler get coreHandler => _coreHandler;

  /// Create a new instance with customized handlers
  FirebaseErrorsHandler copyWith({
    FirebaseAuthHandler? authHandler,
    FirestoreHandler? firestoreHandler,
    FirebaseFunctionsHandler? functionsHandler,
    FirebaseStorageHandler? storageHandler,
    FirebaseCoreHandler? coreHandler,
    int? priority,
  }) {
    return FirebaseErrorsHandler(
      authHandler: authHandler ?? _authHandler,
      firestoreHandler: firestoreHandler ?? _firestoreHandler,
      functionsHandler: functionsHandler ?? _functionsHandler,
      storageHandler: storageHandler ?? _storageHandler,
      coreHandler: coreHandler ?? _coreHandler,
      priority: priority ?? _priority,
    );
  }
}
