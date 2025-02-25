import 'package:arsync_exception_toolkit/arsync_exception_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:supabase/supabase.dart';

import 'supabase_error_codes.dart';

/// Handler specifically for Supabase Functions (Edge Functions) exceptions
class SupabaseFunctionsHandler implements ArsyncExceptionHandler {
  /// Custom error exceptions to override the defaults
  final Map<String, ArsyncException>? customExceptions;

  /// Priority level for this handler (higher means it's tried earlier)
  final int _priority;

  /// Create a Supabase Functions error handler
  ///
  /// [customExceptions] - Optional map to override default error exceptions
  /// [priority] - Priority level for this handler (higher = higher priority)
  SupabaseFunctionsHandler({
    this.customExceptions,
    int priority = 17,
  }) : _priority = priority;

  @override
  bool canHandle(Object exception) {
    if (exception is FunctionException) {
      return true;
    }

    // Check regular exceptions with functions-related messages
    final exceptionStr = exception.toString().toLowerCase();
    return exceptionStr.contains('function') &&
            exceptionStr.contains('error') ||
        exceptionStr.contains('edge function') ||
        exceptionStr.contains('function not found') ||
        exceptionStr.contains('execution failed');
  }

  @override
  ArsyncException handle(Object exception) {
    String code = SupabaseErrorCodes.unknownError;
    String message = 'A function error occurred';

    // Extract error details depending on exception type
    if (exception is FunctionException) {
      code = _extractErrorCode(exception);
      message = exception.toString();
    } else {
      // For other exceptions, try to extract from the string representation
      final exceptionStr = exception.toString();
      code = _extractErrorCode(exception);
      message = exceptionStr;
    }

    // Create a technical details string that includes any extra details
    String technicalDetails = 'Supabase Functions: $code - $message';

    // Check if this error should be ignored
    if (SupabaseErrorCodes.isIgnorable(message)) {
      return ArsyncException.ignored(
        originalException: exception,
        technicalDetails: technicalDetails,
      );
    }

    // Use custom error exceptions if provided and the code exists
    if (customExceptions != null && customExceptions!.containsKey(code)) {
      return customExceptions![code]!.copyWith(
        originalException: exception,
        technicalDetails: technicalDetails,
      );
    }

    // Use default error exceptions
    if (_defaultErrorMap.containsKey(code)) {
      return _defaultErrorMap[code]!.copyWith(
        originalException: exception,
        technicalDetails: technicalDetails,
      );
    }

    // Default error for unknown codes
    return ArsyncException(
      icon: Icons.functions,
      title: 'Function Error',
      message: message,
      briefTitle: 'Function Error',
      briefMessage: 'Function execution failed',
      exceptionCode: 'supabase_function_$code',
      originalException: exception,
      technicalDetails: technicalDetails,
    );
  }

  /// Extract an error code from the exception
  String _extractErrorCode(Object exception) {
    if (exception is FunctionException) {
      // If we have an HTTP status code, use it to help classify the error
      switch (exception.status) {
        case 404:
          return SupabaseErrorCodes.functionNotFound;
        case 400:
          return SupabaseErrorCodes.invalidFunctionPayload;
        case 408:
          return SupabaseErrorCodes.functionTimeout;
        case 500:
          return SupabaseErrorCodes.functionExecutionFailed;
        case 429:
          return SupabaseErrorCodes.rateLimited;
        case 401:
        case 403:
          return SupabaseErrorCodes.unauthorized;
        default:
          break;
      }

      // Check the message for error patterns
      final message = exception.toString();
      return SupabaseErrorCodes.extractErrorCode(message);
    } else {
      // For general exceptions, use the string representation
      return SupabaseErrorCodes.extractErrorCode(exception.toString());
    }
  }

  @override
  int get priority => _priority;

  /// Create a new instance with custom error exceptions
  SupabaseFunctionsHandler withCustomExceptions(
      Map<String, ArsyncException> customExceptions) {
    // Start with a copy of the default map
    final Map<String, ArsyncException> mergedExceptions =
        Map.from(_defaultErrorMap);

    // Override with any custom exceptions
    mergedExceptions.addAll(customExceptions);

    return SupabaseFunctionsHandler(
      customExceptions: mergedExceptions,
      priority: priority,
    );
  }

  /// Default error exceptions for Supabase Functions errors
  static final Map<String, ArsyncException> _defaultErrorMap = {
    SupabaseErrorCodes.functionNotFound: ArsyncException(
      icon: Icons.extension_off,
      title: 'Function Not Found',
      message:
          'The function you\'re trying to call doesn\'t exist. This may be a configuration issue.',
      briefTitle: 'Missing Function',
      briefMessage: 'Function not found',
      exceptionCode: 'supabase_function_not_found',
    ),
    SupabaseErrorCodes.functionExecutionFailed: ArsyncException(
      icon: Icons.dangerous,
      title: 'Function Execution Failed',
      message:
          'The function encountered an error during execution. Please try again or check your input.',
      briefTitle: 'Execution Failed',
      briefMessage: 'Function execution failed',
      exceptionCode: 'supabase_function_execution_failed',
    ),
    SupabaseErrorCodes.functionTimeout: ArsyncException(
      icon: Icons.timer_off,
      title: 'Function Timeout',
      message:
          'The function took too long to complete. Please try again or contact support.',
      briefTitle: 'Timeout',
      briefMessage: 'Function timed out',
      exceptionCode: 'supabase_function_timeout',
    ),
    SupabaseErrorCodes.invalidFunctionPayload: ArsyncException(
      icon: Icons.input,
      title: 'Invalid Function Input',
      message:
          'The data provided to the function is invalid. Please check your input and try again.',
      briefTitle: 'Invalid Input',
      briefMessage: 'Invalid function input',
      exceptionCode: 'supabase_function_invalid_payload',
    ),
    SupabaseErrorCodes.unauthorized: ArsyncException(
      icon: Icons.no_accounts,
      title: 'Function Access Denied',
      message: 'You don\'t have permission to call this function.',
      briefTitle: 'No Access',
      briefMessage: 'Function access denied',
      exceptionCode: 'supabase_function_unauthorized',
    ),
    SupabaseErrorCodes.networkError: ArsyncException(
      icon: Icons.wifi_off,
      title: 'Network Error',
      message:
          'Unable to connect to the function service. Please check your internet connection and try again.',
      briefTitle: 'No Connection',
      briefMessage: 'Network error',
      exceptionCode: 'supabase_function_network_error',
    ),
    SupabaseErrorCodes.timeoutError: ArsyncException(
      icon: Icons.timer_off,
      title: 'Request Timeout',
      message:
          'The function request timed out. Please check your connection and try again.',
      briefTitle: 'Timeout',
      briefMessage: 'Request timed out',
      exceptionCode: 'supabase_function_timeout_error',
    ),
    SupabaseErrorCodes.rateLimited: ArsyncException(
      icon: Icons.speed,
      title: 'Too Many Requests',
      message:
          'You\'ve made too many function calls. Please wait a few moments and try again.',
      briefTitle: 'Rate Limited',
      briefMessage: 'Too many requests',
      exceptionCode: 'supabase_function_rate_limited',
    ),
    SupabaseErrorCodes.serverError: ArsyncException(
      icon: Icons.cloud_off,
      title: 'Function Server Error',
      message:
          'The function server encountered an error. Please try again later.',
      briefTitle: 'Server Error',
      briefMessage: 'Function server error',
      exceptionCode: 'supabase_function_server_error',
    ),
    SupabaseErrorCodes.unknownError: ArsyncException(
      icon: Icons.help_outline,
      title: 'Function Error',
      message:
          'An unexpected function error occurred. Please try again or contact support.',
      briefTitle: 'Function Error',
      briefMessage: 'Function failed',
      exceptionCode: 'supabase_function_unknown_error',
    ),
  };
}
