import 'package:arsync_exception_toolkit/arsync_exception_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:supabase/supabase.dart';

import 'supabase_error_codes.dart';

/// Handler specifically for Supabase Database (PostgreSQL) exceptions
class SupabaseDatabaseHandler implements ArsyncExceptionHandler {
  /// Custom error exceptions to override the defaults
  final Map<String, ArsyncException>? customExceptions;

  /// Priority level for this handler (higher means it's tried earlier)
  final int _priority;

  /// Create a Supabase Database error handler
  ///
  /// [customExceptions] - Optional map to override default error exceptions
  /// [priority] - Priority level for this handler (higher = higher priority)
  SupabaseDatabaseHandler({
    this.customExceptions,
    int priority = 18,
  }) : _priority = priority;

  @override
  bool canHandle(Object exception) {
    if (exception is PostgrestException) {
      return true;
    }

    // Check for common PostgreSQL error code patterns in general exceptions
    final exceptionStr = exception.toString().toLowerCase();
    return exceptionStr.contains('postgrest') ||
        exceptionStr.contains('database error') ||
        exceptionStr.contains('postgresql') ||
        exceptionStr.contains('violates constraint') ||
        exceptionStr.contains('duplicate key') ||
        exceptionStr.contains('relation ');
  }

  @override
  ArsyncException handle(Object exception) {
    String code = SupabaseErrorCodes.unknownError;
    String message = 'A database error occurred';

    // Extract error details depending on exception type
    if (exception is PostgrestException) {
      code = _extractErrorCode(exception);
      message = exception.message;
    } else {
      // For other exceptions, try to extract from the string representation
      final exceptionStr = exception.toString();
      code = _extractErrorCode(exception);
      message = exceptionStr;
    }

    // Check if this error should be ignored
    if (SupabaseErrorCodes.isIgnorable(message)) {
      return ArsyncException.ignored(
        originalException: exception,
        technicalDetails: 'Supabase Database: $code - $message',
      );
    }

    // Use custom error exceptions if provided and the code exists
    if (customExceptions != null && customExceptions!.containsKey(code)) {
      return customExceptions![code]!.copyWith(
        originalException: exception,
        technicalDetails: 'Supabase Database: $code - $message',
      );
    }

    // Use default error exceptions
    if (_defaultErrorMap.containsKey(code)) {
      return _defaultErrorMap[code]!.copyWith(
        originalException: exception,
        technicalDetails: 'Supabase Database: $code - $message',
      );
    }

    // Default error for unknown codes
    return ArsyncException(
      icon: Icons.storage_outlined,
      title: 'Database Error',
      message: message,
      briefTitle: 'Database Error',
      briefMessage: 'Database operation failed',
      exceptionCode: 'supabase_db_$code',
      originalException: exception,
      technicalDetails: 'Supabase Database: $code - $message',
    );
  }

  /// Extract an error code from the exception
  String _extractErrorCode(Object exception) {
    if (exception is PostgrestException) {
      // If code is present and not empty
      if (exception.code != null && exception.code!.isNotEmpty) {
        return exception.code!;
      }

      // Otherwise, try to extract from message
      return SupabaseErrorCodes.extractErrorCode(exception.message);
    } else {
      // For general exceptions, use the string representation
      return SupabaseErrorCodes.extractErrorCode(exception.toString());
    }
  }

  @override
  int get priority => _priority;

  /// Create a new instance with custom error exceptions
  SupabaseDatabaseHandler withCustomExceptions(
      Map<String, ArsyncException> customExceptions) {
    // Start with a copy of the default map
    final Map<String, ArsyncException> mergedExceptions =
        Map.from(_defaultErrorMap);

    // Override with any custom exceptions
    mergedExceptions.addAll(customExceptions);

    return SupabaseDatabaseHandler(
      customExceptions: mergedExceptions,
      priority: priority,
    );
  }

  /// Default error exceptions for Supabase Database errors
  static final Map<String, ArsyncException> _defaultErrorMap = {
    SupabaseErrorCodes.uniqueViolation: ArsyncException(
      icon: Icons.copy_all,
      title: 'Duplicate Entry',
      message:
          'This record already exists in the database. Please try with different data.',
      briefTitle: 'Duplicate Entry',
      briefMessage: 'Record already exists',
      exceptionCode: 'supabase_db_unique_violation',
    ),
    SupabaseErrorCodes.foreignKeyViolation: ArsyncException(
      icon: Icons.link_off,
      title: 'Reference Error',
      message:
          'This operation would violate database references. The referenced record may not exist or cannot be modified.',
      briefTitle: 'Reference Error',
      briefMessage: 'Invalid reference',
      exceptionCode: 'supabase_db_foreign_key_violation',
    ),
    SupabaseErrorCodes.checkViolation: ArsyncException(
      icon: Icons.rule,
      title: 'Validation Error',
      message:
          'The data does not meet the requirements for this field. Please check your input.',
      briefTitle: 'Validation Error',
      briefMessage: 'Data validation failed',
      exceptionCode: 'supabase_db_check_violation',
    ),
    SupabaseErrorCodes.notNullViolation: ArsyncException(
      icon: Icons.text_fields,
      title: 'Missing Required Field',
      message:
          'A required field is missing. Please complete all required fields.',
      briefTitle: 'Missing Field',
      briefMessage: 'Required field missing',
      exceptionCode: 'supabase_db_not_null_violation',
    ),
    SupabaseErrorCodes.tableNotFound: ArsyncException(
      icon: Icons.table_chart_outlined,
      title: 'Table Not Found',
      message:
          'The database table you\'re trying to access doesn\'t exist. This may be a configuration issue.',
      briefTitle: 'Missing Table',
      briefMessage: 'Table not found',
      exceptionCode: 'supabase_db_table_not_found',
    ),
    SupabaseErrorCodes.columnNotFound: ArsyncException(
      icon: Icons.view_column_outlined,
      title: 'Column Not Found',
      message:
          'The database field you\'re trying to access doesn\'t exist. This may be a configuration issue.',
      briefTitle: 'Missing Column',
      briefMessage: 'Column not found',
      exceptionCode: 'supabase_db_column_not_found',
    ),
    SupabaseErrorCodes.insufficientPrivilege: ArsyncException(
      icon: Icons.no_accounts,
      title: 'Permission Denied',
      message: 'You don\'t have permission to perform this database operation.',
      briefTitle: 'No Permission',
      briefMessage: 'Access denied',
      exceptionCode: 'supabase_db_insufficient_privilege',
    ),
    SupabaseErrorCodes.syntaxError: ArsyncException(
      icon: Icons.code,
      title: 'Query Syntax Error',
      message:
          'There\'s a syntax error in the database query. This is likely a development issue.',
      briefTitle: 'Syntax Error',
      briefMessage: 'Query syntax error',
      exceptionCode: 'supabase_db_syntax_error',
    ),
    SupabaseErrorCodes.invalidParameter: ArsyncException(
      icon: Icons.input,
      title: 'Invalid Parameter',
      message:
          'One of the parameters provided to the database is invalid. Please check your input.',
      briefTitle: 'Invalid Input',
      briefMessage: 'Invalid parameter',
      exceptionCode: 'supabase_db_invalid_parameter',
    ),
    SupabaseErrorCodes.dataException: ArsyncException(
      icon: Icons.data_object,
      title: 'Data Error',
      message:
          'There was an error processing the data. The input may be in an incorrect format.',
      briefTitle: 'Data Error',
      briefMessage: 'Data processing error',
      exceptionCode: 'supabase_db_data_exception',
    ),
    SupabaseErrorCodes.connectionFailure: ArsyncException(
      icon: Icons.wifi_off,
      title: 'Database Connection Error',
      message:
          'Unable to connect to the database. Please check your internet connection and try again.',
      briefTitle: 'Connection Error',
      briefMessage: 'Database connection failed',
      exceptionCode: 'supabase_db_connection_failure',
    ),
    SupabaseErrorCodes.networkError: ArsyncException(
      icon: Icons.wifi_off,
      title: 'Network Error',
      message:
          'Unable to connect to the database service. Please check your internet connection and try again.',
      briefTitle: 'No Connection',
      briefMessage: 'Network error',
      exceptionCode: 'supabase_db_network_error',
    ),
    SupabaseErrorCodes.timeoutError: ArsyncException(
      icon: Icons.timer_off,
      title: 'Database Timeout',
      message:
          'The database operation timed out. Please try again later or check your query.',
      briefTitle: 'Timeout',
      briefMessage: 'Operation timed out',
      exceptionCode: 'supabase_db_timeout_error',
    ),
    SupabaseErrorCodes.serverError: ArsyncException(
      icon: Icons.cloud_off,
      title: 'Database Server Error',
      message:
          'The database server encountered an error. Please try again later.',
      briefTitle: 'Server Error',
      briefMessage: 'Database server error',
      exceptionCode: 'supabase_db_server_error',
    ),
    SupabaseErrorCodes.unknownError: ArsyncException(
      icon: Icons.help_outline,
      title: 'Database Error',
      message:
          'An unexpected database error occurred. Please try again or contact support.',
      briefTitle: 'Database Error',
      briefMessage: 'Database operation failed',
      exceptionCode: 'supabase_db_unknown_error',
    ),
  };
}
