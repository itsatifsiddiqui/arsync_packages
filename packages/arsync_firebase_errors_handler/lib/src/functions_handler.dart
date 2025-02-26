import 'package:cloud_functions_platform_interface/cloud_functions_platform_interface.dart'
    show FirebaseFunctionsException;
import 'package:flutter/material.dart';
import 'package:arsync_exception_toolkit/arsync_exception_toolkit.dart';

import 'firebase_error_codes.dart';

/// Handler specifically for Firebase Cloud Functions exceptions
class FirebaseFunctionsHandler implements ArsyncExceptionHandler {
  /// Custom error exceptions to override the defaults
  final Map<String, ArsyncException>? customExceptions;

  /// Priority level for this handler (higher means it's tried earlier)
  final int _priority;

  /// Create a Firebase Functions error handler
  ///
  /// [customExceptions] - Optional map to override default error exceptions
  /// [priority] - Priority level for this handler (higher = higher priority)
  FirebaseFunctionsHandler({
    this.customExceptions,
    int priority = 17,
  }) : _priority = priority;

  @override
  bool canHandle(Object exception) {
    return exception is FirebaseFunctionsException;
  }

  @override
  ArsyncException handle(Object exception) {
    final functionsException = exception as FirebaseFunctionsException;
    final code = functionsException.code;

    // Handle ignorable exceptions
    if (FirebaseErrorCodes.isIgnorable(code)) {
      return ArsyncException.ignored(
        originalException: exception,
        technicalDetails:
            'Firebase Functions: $code - ${functionsException.message}',
      );
    }

    // Check for additional details in the exception
    final details = functionsException.details;
    String technicalDetails =
        'Firebase Functions: $code - ${functionsException.message}';

    if (details != null) {
      if (details is Map) {
        // Try to create a formatted JSON string of the details
        try {
          final buffer = StringBuffer();
          buffer.writeln(
              'Firebase Functions: $code - ${functionsException.message}');
          buffer.writeln('Details:');
          details.forEach((key, value) {
            buffer.writeln('  $key: $value');
          });
          technicalDetails = buffer.toString();
        } catch (_) {
          // If that fails, just append the details as a string
          technicalDetails = '$technicalDetails\nDetails: $details';
        }
      } else {
        // If details is not a map, just append it as a string
        technicalDetails = '$technicalDetails\nDetails: $details';
      }
    }

    // Use custom error exceptions if provided and the code exists
    if (customExceptions != null && customExceptions!.containsKey(code)) {
      // Return a copy with the original exception and technical details
      return customExceptions![code]!.copyWith(
        originalException: exception,
        technicalDetails: technicalDetails,
      );
    }

    // Use default error exceptions
    if (_defaultErrorMap.containsKey(code)) {
      // Return a copy with the original exception and technical details
      return _defaultErrorMap[code]!.copyWith(
        originalException: exception,
        technicalDetails: technicalDetails,
      );
    }

    // Default error for unknown codes
    return ArsyncException(
      icon: Icons.cloud_outlined,
      title: 'Cloud Function Error',
      message: functionsException.message ??
          'An unexpected error occurred in a cloud function',
      briefTitle: 'Function Error',
      briefMessage: 'Cloud function failed',
      exceptionCode: 'firebase_functions_$code',
      originalException: exception,
      technicalDetails: technicalDetails,
    );
  }

  @override
  int get priority => _priority;

  /// Create a new instance with custom error exceptions
  FirebaseFunctionsHandler withCustomExceptions(
      Map<String, ArsyncException> customExceptions) {
    // Start with a copy of the default map
    final Map<String, ArsyncException> mergedExceptions =
        Map.from(_defaultErrorMap);

    // Override with any custom exceptions
    mergedExceptions.addAll(customExceptions);

    return FirebaseFunctionsHandler(
      customExceptions: mergedExceptions,
      priority: priority,
    );
  }

  /// Default error exceptions for Firebase Functions errors
  static final Map<String, ArsyncException> _defaultErrorMap = {
    FirebaseErrorCodes.invalidArgument: ArsyncException(
      icon: Icons.warning_amber_outlined,
      title: 'Invalid Input',
      message:
          'Some of the information you provided is invalid. Please check and try again.',
      briefTitle: 'Invalid Input',
      briefMessage: 'Invalid input',
      exceptionCode: 'firebase_functions_invalid_argument',
    ),
    FirebaseErrorCodes.notFound: ArsyncException(
      icon: Icons.find_replace,
      title: 'Not Found',
      message: 'The requested resource could not be found.',
      briefTitle: 'Not Found',
      briefMessage: 'Resource not found',
      exceptionCode: 'firebase_functions_not_found',
    ),
    FirebaseErrorCodes.permissionDenied: ArsyncException(
      icon: Icons.no_accounts,
      title: 'Access Denied',
      message:
          'You don\'t have permission to perform this action. Please contact support if you need access.',
      briefTitle: 'Access Denied',
      briefMessage: 'No permission',
      exceptionCode: 'firebase_functions_permission_denied',
    ),
    FirebaseErrorCodes.unauthenticated: ArsyncException(
      icon: Icons.lock_outline,
      title: 'Authentication Required',
      message: 'You need to be signed in to perform this action.',
      briefTitle: 'Sign In Required',
      briefMessage: 'Authentication required',
      exceptionCode: 'firebase_functions_unauthenticated',
    ),
    FirebaseErrorCodes.resourceExhausted: ArsyncException(
      icon: Icons.battery_alert,
      title: 'Resource Limit Reached',
      message:
          'The system has reached the maximum limit for this resource. Please try again later or contact support.',
      briefTitle: 'Limit Reached',
      briefMessage: 'Resource limit reached',
      exceptionCode: 'firebase_functions_resource_exhausted',
    ),
    FirebaseErrorCodes.failedPrecondition: ArsyncException(
      icon: Icons.warning_amber_outlined,
      title: 'Action Not Allowed',
      message:
          'This action cannot be completed because some requirements are not met.',
      briefTitle: 'Requirements Not Met',
      briefMessage: 'Requirements not met',
      exceptionCode: 'firebase_functions_failed_precondition',
    ),
    FirebaseErrorCodes.aborted: ArsyncException(
      icon: Icons.cancel_outlined,
      title: 'Operation Aborted',
      message: 'The operation was aborted. Please try again.',
      briefTitle: 'Aborted',
      briefMessage: 'Operation aborted',
      exceptionCode: 'firebase_functions_aborted',
    ),
    FirebaseErrorCodes.deadlineExceeded: ArsyncException(
      icon: Icons.timer_off,
      title: 'Function Timeout',
      message: 'The function took too long to complete. Please try again.',
      briefTitle: 'Timeout',
      briefMessage: 'Function timed out',
      exceptionCode: 'firebase_functions_deadline_exceeded',
    ),
    FirebaseErrorCodes.unavailable: ArsyncException(
      icon: Icons.cloud_off,
      title: 'Service Down',
      message:
          'Our service is temporarily unavailable. We\'re working to restore it. Please try again soon.',
      briefTitle: 'Service Unavailable',
      briefMessage: 'Service down',
      exceptionCode: 'firebase_functions_unavailable',
    ),
    FirebaseErrorCodes.internalError: ArsyncException(
      icon: Icons.warning_amber_outlined,
      title: 'System Error',
      message:
          'Something went wrong on our end. We\'re working to fix it. Please try again later.',
      briefTitle: 'System Error',
      briefMessage: 'System error',
      exceptionCode: 'firebase_functions_internal_error',
    ),
    FirebaseErrorCodes.unimplemented: ArsyncException(
      icon: Icons.build_circle,
      title: 'Not Implemented',
      message:
          'The function you\'re trying to use is not implemented or not supported yet.',
      briefTitle: 'Not Implemented',
      briefMessage: 'Feature not available',
      exceptionCode: 'firebase_functions_unimplemented',
    ),
    FirebaseErrorCodes.cancelled: ArsyncException(
      icon: Icons.cancel_outlined,
      title: 'Request Cancelled',
      message: 'The operation was cancelled. Please try again if needed.',
      briefTitle: 'Cancelled',
      briefMessage: 'Cancelled',
      exceptionCode: 'firebase_functions_cancelled',
    ),
    FirebaseErrorCodes.networkRequestFailed: ArsyncException(
      icon: Icons.wifi_off,
      title: 'Connection Error',
      message:
          'Unable to connect to our servers. Please check your internet connection and try again.',
      briefTitle: 'No Connection',
      briefMessage: 'Network error',
      exceptionCode: 'firebase_functions_network_request_failed',
    ),
    FirebaseErrorCodes.unknown: ArsyncException(
      icon: Icons.help_outline,
      title: 'Unexpected Error',
      message:
          'An unexpected error occurred in a cloud function. Please try again or contact support if the problem persists.',
      briefTitle: 'Unknown Error',
      briefMessage: 'Unknown error',
      exceptionCode: 'firebase_functions_unknown',
    ),
  };
}
