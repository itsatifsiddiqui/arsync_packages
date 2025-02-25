import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart' show FirebaseException;
import 'package:flutter/material.dart';
import 'package:arsync_exception_toolkit/arsync_exception_toolkit.dart';

import 'firebase_error_codes.dart';

/// Handler specifically for Firestore exceptions
class FirestoreHandler implements ArsyncExceptionHandler {
  /// Custom error exceptions to override the defaults
  final Map<String, ArsyncException>? customExceptions;

  /// Priority level for this handler (higher means it's tried earlier)
  final int _priority;

  /// Create a Firestore error handler
  ///
  /// [customExceptions] - Optional map to override default error exceptions
  /// [priority] - Priority level for this handler (higher = higher priority)
  FirestoreHandler({
    this.customExceptions,
    int priority = 18,
  }) : _priority = priority;

  @override
  bool canHandle(Object exception) {
    return exception is FirebaseException && 
           exception.plugin == 'cloud_firestore';
  }

  @override
  ArsyncException handle(Object exception) {
    final firestoreException = exception as FirebaseException;
    final code = firestoreException.code;

    // Handle ignorable exceptions
    if (FirebaseErrorCodes.isIgnorable(code)) {
      return ArsyncException.ignored(
        originalException: exception,
        technicalDetails: 'Firestore: $code - ${firestoreException.message}',
      );
    }

    // Use custom error exceptions if provided and the code exists
    if (customExceptions != null && customExceptions!.containsKey(code)) {
      // Return a copy with the original exception and technical details
      return customExceptions![code]!.copyWith(
        originalException: exception,
        technicalDetails: 'Firestore: $code - ${firestoreException.message}',
      );
    }

    // Use default error exceptions
    if (_defaultErrorMap.containsKey(code)) {
      // Return a copy with the original exception and technical details
      return _defaultErrorMap[code]!.copyWith(
        originalException: exception,
        technicalDetails: 'Firestore: $code - ${firestoreException.message}',
      );
    }

    // Default error for unknown codes
    return ArsyncException(
      icon: Icons.storage_outlined,
      title: 'Database Error',
      message: firestoreException.message ?? 'An unexpected database error occurred',
      briefTitle: 'Database Error',
      briefMessage: 'Database operation failed',
      exceptionCode: 'firestore_$code',
      originalException: exception,
      technicalDetails: 'Firestore: $code - ${firestoreException.message}',
    );
  }

  @override
  int get priority => _priority;

  /// Create a new instance with custom error exceptions
  FirestoreHandler withCustomExceptions(
    Map<String, ArsyncException> customExceptions
  ) {
    // Start with a copy of the default map
    final Map<String, ArsyncException> mergedExceptions = Map.from(_defaultErrorMap);
    
    // Override with any custom exceptions
    mergedExceptions.addAll(customExceptions);
    
    return FirestoreHandler(
      customExceptions: mergedExceptions,
      priority: priority,
    );
  }

  /// Default error exceptions for Firestore errors
  static final Map<String, ArsyncException> _defaultErrorMap = {
    FirebaseErrorCodes.permissionDenied: ArsyncException(
      icon: Icons.no_accounts,
      title: 'Access Denied',
      message: 'You don\'t have permission to perform this action. Please contact support if you need access.',
      briefTitle: 'Access Denied',
      briefMessage: 'No permission',
      exceptionCode: 'firestore_permission_denied',
    ),
    
    FirebaseErrorCodes.unavailable: ArsyncException(
      icon: Icons.cloud_off,
      title: 'Service Down',
      message: 'Our service is temporarily unavailable. We\'re working to restore it. Please try again soon.',
      briefTitle: 'Service Unavailable',
      briefMessage: 'Service down',
      exceptionCode: 'firestore_unavailable',
    ),
    
    FirebaseErrorCodes.notFound: ArsyncException(
      icon: Icons.find_replace,
      title: 'Not Found',
      message: 'The requested information could not be found. It may have been deleted or moved.',
      briefTitle: 'Not Found',
      briefMessage: 'Resource not found',
      exceptionCode: 'firestore_not_found',
    ),
    
    FirebaseErrorCodes.alreadyExists: ArsyncException(
      icon: Icons.warning_amber_outlined,
      title: 'Duplicate Entry',
      message: 'This information already exists in our system. Please modify and try again.',
      briefTitle: 'Already Exists',
      briefMessage: 'Already exists',
      exceptionCode: 'firestore_already_exists',
    ),
    
    FirebaseErrorCodes.dataLoss: ArsyncException(
      icon: Icons.data_array,
      title: 'Data Error',
      message: 'Some data was lost during the operation. Please try again or contact support.',
      briefTitle: 'Data Error',
      briefMessage: 'Data error',
      exceptionCode: 'firestore_data_loss',
    ),
    
    FirebaseErrorCodes.invalidArgument: ArsyncException(
      icon: Icons.warning_amber_outlined,
      title: 'Invalid Input',
      message: 'Some of the information you provided is invalid. Please check and try again.',
      briefTitle: 'Invalid Input',
      briefMessage: 'Invalid input',
      exceptionCode: 'firestore_invalid_argument',
    ),
    
    FirebaseErrorCodes.resourceExhausted: ArsyncException(
      icon: Icons.battery_alert,
      title: 'Resource Limit Reached',
      message: 'System has reached the maximum limit for this resource. Please contact support.',
      briefTitle: 'Limit Reached',
      briefMessage: 'Limit reached',
      exceptionCode: 'firestore_resource_exhausted',
    ),
    
    FirebaseErrorCodes.failedPrecondition: ArsyncException(
      icon: Icons.warning_amber_outlined,
      title: 'Action Not Allowed',
      message: 'This action cannot be completed because some requirements are not met.',
      briefTitle: 'Requirements Not Met',
      briefMessage: 'Requirements not met',
      exceptionCode: 'firestore_failed_precondition',
    ),
    
    FirebaseErrorCodes.aborted: ArsyncException(
      icon: Icons.cancel_outlined,
      title: 'Operation Aborted',
      message: 'The operation was aborted. Please try again.',
      briefTitle: 'Aborted',
      briefMessage: 'Operation aborted',
      exceptionCode: 'firestore_aborted',
    ),
    
    FirebaseErrorCodes.deadlineExceeded: ArsyncException(
      icon: Icons.timer_off,
      title: 'Operation Timeout',
      message: 'The operation took too long to complete. Please try again.',
      briefTitle: 'Timeout',
      briefMessage: 'Operation timed out',
      exceptionCode: 'firestore_deadline_exceeded',
    ),
    
    FirebaseErrorCodes.outOfRange: ArsyncException(
      icon: Icons.error_outline,
      title: 'Out of Range',
      message: 'Operation was attempted past the valid range.',
      briefTitle: 'Out of Range',
      briefMessage: 'Value out of range',
      exceptionCode: 'firestore_out_of_range',
    ),
    
    FirebaseErrorCodes.unimplemented: ArsyncException(
      icon: Icons.build_circle,
      title: 'Not Implemented',
      message: 'The operation you\'re trying to use is not implemented or not supported yet.',
      briefTitle: 'Not Implemented',
      briefMessage: 'Feature not available',
      exceptionCode: 'firestore_unimplemented',
    ),
    
    FirebaseErrorCodes.unauthenticated: ArsyncException(
      icon: Icons.lock_outline,
      title: 'Authentication Required',
      message: 'You need to be signed in to perform this action.',
      briefTitle: 'Sign In Required',
      briefMessage: 'Authentication required',
      exceptionCode: 'firestore_unauthenticated',
    ),
    
    FirebaseErrorCodes.networkRequestFailed: ArsyncException(
      icon: Icons.wifi_off,
      title: 'Connection Error',
      message: 'Unable to connect to our servers. Please check your internet connection and try again.',
      briefTitle: 'No Connection',
      briefMessage: 'Network error',
      exceptionCode: 'firestore_network_request_failed',
    ),
    
    FirebaseErrorCodes.cancelled: ArsyncException(
      icon: Icons.cancel_outlined,
      title: 'Request Cancelled',
      message: 'The operation was cancelled. Please try again if needed.',
      briefTitle: 'Cancelled',
      briefMessage: 'Cancelled',
      exceptionCode: 'firestore_cancelled',
    ),
    
    FirebaseErrorCodes.unknown: ArsyncException(
      icon: Icons.help_outline,
      title: 'Unexpected Error',
      message: 'An unexpected database error occurred. Please try again or contact support if the problem persists.',
      briefTitle: 'Unknown Error',
      briefMessage: 'Unknown error',
      exceptionCode: 'firestore_unknown',
    ),
  };
}