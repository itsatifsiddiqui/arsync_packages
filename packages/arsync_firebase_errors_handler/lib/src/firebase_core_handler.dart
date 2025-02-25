import 'package:arsync_exception_toolkit/arsync_exception_toolkit.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart'
    show FirebaseException;
import 'package:flutter/material.dart';

import 'firebase_error_codes.dart';

/// Handler for generic Firebase Core exceptions
///
/// This handles Firebase exceptions that aren't specific to a particular
/// Firebase service or when the service can't be identified.
class FirebaseCoreHandler implements ArsyncExceptionHandler {
  /// Custom error exceptions to override the defaults
  final Map<String, ArsyncException>? customExceptions;

  /// Priority level for this handler (higher means it's tried earlier)
  final int _priority;

  /// Create a Firebase Core error handler
  ///
  /// [customExceptions] - Optional map to override default error exceptions
  /// [priority] - Priority level for this handler (higher = higher priority)
  FirebaseCoreHandler({
    this.customExceptions,
    int priority = 15,
  }) : _priority = priority;

  @override
  bool canHandle(Object exception) {
    // Handle generic Firebase exceptions or those that don't have a specific plugin
    return exception is FirebaseException &&
        (exception.plugin == 'core' || exception.plugin.isEmpty);
  }

  @override
  ArsyncException handle(Object exception) {
    final firebaseException = exception as FirebaseException;
    final code = firebaseException.code;

    // Handle ignorable exceptions
    if (FirebaseErrorCodes.isIgnorable(code)) {
      return ArsyncException.ignored(
        originalException: exception,
        technicalDetails: 'Firebase Core: $code - ${firebaseException.message}',
      );
    }

    // Use custom error exceptions if provided and the code exists
    if (customExceptions != null && customExceptions!.containsKey(code)) {
      // Return a copy with the original exception and technical details
      return customExceptions![code]!.copyWith(
        originalException: exception,
        technicalDetails: 'Firebase Core: $code - ${firebaseException.message}',
      );
    }

    // Use default error exceptions
    if (_defaultErrorMap.containsKey(code)) {
      // Return a copy with the original exception and technical details
      return _defaultErrorMap[code]!.copyWith(
        originalException: exception,
        technicalDetails: 'Firebase Core: $code - ${firebaseException.message}',
      );
    }

    // Default error for unknown codes
    return ArsyncException(
      icon: Icons.error_outline,
      title: 'Firebase Error',
      message:
          firebaseException.message ?? 'An unexpected Firebase error occurred',
      briefTitle: 'Firebase Error',
      briefMessage: 'Firebase operation failed',
      exceptionCode: 'firebase_core_$code',
      originalException: exception,
      technicalDetails: 'Firebase Core: $code - ${firebaseException.message}',
    );
  }

  @override
  int get priority => _priority;

  /// Create a new instance with custom error exceptions
  FirebaseCoreHandler withCustomExceptions(
      Map<String, ArsyncException> customExceptions) {
    // Start with a copy of the default map
    final Map<String, ArsyncException> mergedExceptions =
        Map.from(_defaultErrorMap);

    // Override with any custom exceptions
    mergedExceptions.addAll(customExceptions);

    return FirebaseCoreHandler(
      customExceptions: mergedExceptions,
      priority: priority,
    );
  }

  /// Default error exceptions for Firebase Core errors
  static final Map<String, ArsyncException> _defaultErrorMap = {
    FirebaseErrorCodes.networkRequestFailed: ArsyncException(
      icon: Icons.wifi_off,
      title: 'Connection Error',
      message:
          'Unable to connect to Firebase services. Please check your internet connection and try again.',
      briefTitle: 'No Connection',
      briefMessage: 'Network error',
      exceptionCode: 'firebase_core_network_request_failed',
    ),
    FirebaseErrorCodes.timeout: ArsyncException(
      icon: Icons.timer_off,
      title: 'Connection Timeout',
      message:
          'The Firebase operation took too long to complete. Please check your connection and try again.',
      briefTitle: 'Request Timeout',
      briefMessage: 'Request timeout',
      exceptionCode: 'firebase_core_timeout',
    ),
    FirebaseErrorCodes.appNotAuthorized: ArsyncException(
      icon: Icons.gpp_bad,
      title: 'App Not Authorized',
      message:
          'This app is not authorized to use Firebase. Please check the configuration.',
      briefTitle: 'Not Authorized',
      briefMessage: 'App not authorized',
      exceptionCode: 'firebase_core_app_not_authorized',
    ),
    FirebaseErrorCodes.noSuchProvider: ArsyncException(
      icon: Icons.link_off,
      title: 'Provider Not Available',
      message:
          'The requested authentication provider is not available or not enabled.',
      briefTitle: 'Provider Unavailable',
      briefMessage: 'Provider not available',
      exceptionCode: 'firebase_core_no_such_provider',
    ),
    FirebaseErrorCodes.operationNotAllowed: ArsyncException(
      icon: Icons.block,
      title: 'Operation Not Allowed',
      message:
          'This operation is not allowed. Please contact support if you think this is a mistake.',
      briefTitle: 'Not Allowed',
      briefMessage: 'Operation not permitted',
      exceptionCode: 'firebase_core_operation_not_allowed',
    ),
    FirebaseErrorCodes.internalError: ArsyncException(
      icon: Icons.warning_amber_outlined,
      title: 'Firebase System Error',
      message:
          'Something went wrong in Firebase. Our team has been notified. Please try again later.',
      briefTitle: 'System Error',
      briefMessage: 'Firebase system error',
      exceptionCode: 'firebase_core_internal_error',
    ),
    FirebaseErrorCodes.invalidApiKey: ArsyncException(
      icon: Icons.vpn_key_off,
      title: 'Invalid API Key',
      message:
          'The Firebase API key is invalid. Please check your Firebase configuration.',
      briefTitle: 'Invalid API Key',
      briefMessage: 'Invalid Firebase configuration',
      exceptionCode: 'firebase_core_invalid_api_key',
    ),
    FirebaseErrorCodes.appNotInstalled: ArsyncException(
      icon: Icons.app_shortcut,
      title: 'App Not Installed',
      message: 'The requested app is not installed on this device.',
      briefTitle: 'App Not Installed',
      briefMessage: 'Required app not installed',
      exceptionCode: 'firebase_core_app_not_installed',
    ),
    FirebaseErrorCodes.unknown: ArsyncException(
      icon: Icons.help_outline,
      title: 'Unexpected Firebase Error',
      message:
          'An unexpected error occurred with Firebase. Please try again or contact support if the problem persists.',
      briefTitle: 'Unknown Error',
      briefMessage: 'Unknown Firebase error',
      exceptionCode: 'firebase_core_unknown',
    ),
  };
}
