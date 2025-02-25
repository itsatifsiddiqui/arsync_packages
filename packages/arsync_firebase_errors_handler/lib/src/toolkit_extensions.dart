import 'package:arsync_exception_toolkit/arsync_exception_toolkit.dart';

import './firebase_auth_handler.dart';
import './firebase_core_handler.dart';
import './firebase_errors_handler.dart';
import './firestore_handler.dart';
import './functions_handler.dart';
import './storage_handler.dart';

/// Extension methods for ArsyncExceptionToolkit to work with Firebase handlers
extension FirebaseToolkitExtensions on ArsyncExceptionToolkit {
  /// Add a Firebase Auth handler to the toolkit
  ///
  /// [customExceptions] - Optional custom error exceptions for the handler
  /// [priority] - Optional priority for the handler
  ///
  /// Returns the toolkit instance for chaining
  ArsyncExceptionToolkit withFirebaseAuthHandler({
    Map<String, ArsyncException>? customExceptions,
    int priority = 20,
  }) {
    exceptionMapper.handlers.add(
      FirebaseAuthHandler(
        customExceptions: customExceptions,
        priority: priority,
      ),
    );
    return this;
  }

  /// Add a Firestore handler to the toolkit
  ///
  /// [customExceptions] - Optional custom error exceptions for the handler
  /// [priority] - Optional priority for the handler
  ///
  /// Returns the toolkit instance for chaining
  ArsyncExceptionToolkit withFirestoreHandler({
    Map<String, ArsyncException>? customExceptions,
    int priority = 18,
  }) {
    exceptionMapper.handlers.add(
      FirestoreHandler(
        customExceptions: customExceptions,
        priority: priority,
      ),
    );
    return this;
  }

  /// Add a Firebase Functions handler to the toolkit
  ///
  /// [customExceptions] - Optional custom error exceptions for the handler
  /// [priority] - Optional priority for the handler
  ///
  /// Returns the toolkit instance for chaining
  ArsyncExceptionToolkit withFirebaseFunctionsHandler({
    Map<String, ArsyncException>? customExceptions,
    int priority = 17,
  }) {
    exceptionMapper.handlers.add(
      FirebaseFunctionsHandler(
        customExceptions: customExceptions,
        priority: priority,
      ),
    );
    return this;
  }

  /// Add a Firebase Storage handler to the toolkit
  ///
  /// [customExceptions] - Optional custom error exceptions for the handler
  /// [priority] - Optional priority for the handler
  ///
  /// Returns the toolkit instance for chaining
  ArsyncExceptionToolkit withFirebaseStorageHandler({
    Map<String, ArsyncException>? customExceptions,
    int priority = 16,
  }) {
    exceptionMapper.handlers.add(
      FirebaseStorageHandler(
        customExceptions: customExceptions,
        priority: priority,
      ),
    );
    return this;
  }

  /// Add a Firebase Core handler to the toolkit
  ///
  /// [customExceptions] - Optional custom error exceptions for the handler
  /// [priority] - Optional priority for the handler
  ///
  /// Returns the toolkit instance for chaining
  ArsyncExceptionToolkit withFirebaseCoreHandler({
    Map<String, ArsyncException>? customExceptions,
    int priority = 15,
  }) {
    exceptionMapper.handlers.add(
      FirebaseCoreHandler(
        customExceptions: customExceptions,
        priority: priority,
      ),
    );
    return this;
  }

  /// Add all Firebase handlers to the toolkit
  ///
  /// [authHandler] - Optional custom Firebase Auth handler
  /// [firestoreHandler] - Optional custom Firestore handler
  /// [functionsHandler] - Optional custom Functions handler
  /// [storageHandler] - Optional custom Storage handler
  /// [coreHandler] - Optional custom Core handler
  /// [priority] - Optional priority for the combined handler
  ///
  /// Returns the toolkit instance for chaining
  ArsyncExceptionToolkit withAllFirebaseHandlers({
    FirebaseAuthHandler? authHandler,
    FirestoreHandler? firestoreHandler,
    FirebaseFunctionsHandler? functionsHandler,
    FirebaseStorageHandler? storageHandler,
    FirebaseCoreHandler? coreHandler,
    int priority = 25,
  }) {
    exceptionMapper.handlers.add(
      FirebaseErrorsHandler(
        authHandler: authHandler,
        firestoreHandler: firestoreHandler,
        functionsHandler: functionsHandler,
        storageHandler: storageHandler,
        coreHandler: coreHandler,
        priority: priority,
      ),
    );
    return this;
  }
}

/// Extension methods for ArsyncExceptionMapper to work with Firebase handlers
extension FirebaseMapperExtensions on List<ArsyncExceptionHandler> {
  /// Add a Firebase Auth handler to the mapper
  ///
  /// [customExceptions] - Optional custom error exceptions for the handler
  /// [priority] - Optional priority for the handler
  void addFirebaseAuthHandler({
    Map<String, ArsyncException>? customExceptions,
    int priority = 20,
  }) {
    add(
      FirebaseAuthHandler(
        customExceptions: customExceptions,
        priority: priority,
      ),
    );
  }

  /// Add a Firestore handler to the mapper
  ///
  /// [customExceptions] - Optional custom error exceptions for the handler
  /// [priority] - Optional priority for the handler
  void addFirestoreHandler({
    Map<String, ArsyncException>? customExceptions,
    int priority = 18,
  }) {
    add(
      FirestoreHandler(
        customExceptions: customExceptions,
        priority: priority,
      ),
    );
  }

  /// Add a Firebase Functions handler to the mapper
  ///
  /// [customExceptions] - Optional custom error exceptions for the handler
  /// [priority] - Optional priority for the handler
  void addFirebaseFunctionsHandler({
    Map<String, ArsyncException>? customExceptions,
    int priority = 17,
  }) {
    add(
      FirebaseFunctionsHandler(
        customExceptions: customExceptions,
        priority: priority,
      ),
    );
  }

  /// Add a Firebase Storage handler to the mapper
  ///
  /// [customExceptions] - Optional custom error exceptions for the handler
  /// [priority] - Optional priority for the handler
  void addFirebaseStorageHandler({
    Map<String, ArsyncException>? customExceptions,
    int priority = 16,
  }) {
    add(
      FirebaseStorageHandler(
        customExceptions: customExceptions,
        priority: priority,
      ),
    );
  }

  /// Add a Firebase Core handler to the mapper
  ///
  /// [customExceptions] - Optional custom error exceptions for the handler
  /// [priority] - Optional priority for the handler
  void addFirebaseCoreHandler({
    Map<String, ArsyncException>? customExceptions,
    int priority = 15,
  }) {
    add(
      FirebaseCoreHandler(
        customExceptions: customExceptions,
        priority: priority,
      ),
    );
  }

  /// Add all Firebase handlers to the mapper
  ///
  /// [authHandler] - Optional custom Firebase Auth handler
  /// [firestoreHandler] - Optional custom Firestore handler
  /// [functionsHandler] - Optional custom Functions handler
  /// [storageHandler] - Optional custom Storage handler
  /// [coreHandler] - Optional custom Core handler
  /// [priority] - Optional priority for the combined handler
  void addAllFirebaseHandlers({
    FirebaseAuthHandler? authHandler,
    FirestoreHandler? firestoreHandler,
    FirebaseFunctionsHandler? functionsHandler,
    FirebaseStorageHandler? storageHandler,
    FirebaseCoreHandler? coreHandler,
    int priority = 25,
  }) {
    add(
      FirebaseErrorsHandler(
        authHandler: authHandler,
        firestoreHandler: firestoreHandler,
        functionsHandler: functionsHandler,
        storageHandler: storageHandler,
        coreHandler: coreHandler,
        priority: priority,
      ),
    );
  }
}
