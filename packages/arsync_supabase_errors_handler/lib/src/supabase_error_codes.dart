/// Constants for Supabase error codes and patterns
class SupabaseErrorCodes {
  // Auth Error Codes
  static const String invalidCredentials = 'invalid_credentials';
  static const String userNotFound = 'user_not_found';
  static const String emailNotConfirmed = 'email_not_confirmed';
  static const String invalidToken = 'invalid_token';
  static const String tokenExpired = 'token_expired';
  static const String invalidGrantType = 'invalid_grant_type';
  static const String invalidEmail = 'invalid_email';
  static const String duplicateEmail = 'duplicate_email';
  static const String weakPassword = 'weak_password';
  static const String userAlreadyExists = 'user_already_exists';
  static const String emailTaken = 'email_taken';
  static const String invalidMfaType = 'invalid_mfa_type';
  static const String mfaNotEnabled = 'mfa_not_enabled';
  static const String invalidMfaCode = 'invalid_mfa_code';
  static const String phoneAlreadyConfirmed = 'phone_already_confirmed';

  // Database Error Codes (PostgreSQL)
  static const String uniqueViolation = '23505'; // Unique constraint violation
  static const String foreignKeyViolation = '23503'; // Foreign key violation
  static const String checkViolation = '23514'; // Check constraint violation
  static const String notNullViolation = '23502'; // Not null constraint violation
  static const String tableNotFound = '42P01'; // Relation does not exist
  static const String columnNotFound = '42703'; // Column does not exist
  static const String insufficientPrivilege = '42501'; // Insufficient privilege
  static const String syntaxError = '42601'; // Syntax error
  static const String invalidParameter = '22023'; // Invalid parameter value
  static const String dataException = '22000'; // Data exception
  static const String connectionFailure = '08000'; // Connection issue

  // Storage Error Codes
  static const String objectNotFound = 'object_not_found';
  static const String bucketNotFound = 'bucket_not_found';
  static const String unauthorized = 'unauthorized';
  static const String insufficientStorage = 'insufficient_storage';
  static const String quotaExceeded = 'quota_exceeded';
  static const String fileTooBig = 'file_too_big';
  static const String invalidContentType = 'invalid_content_type';
  static const String invalidFilename = 'invalid_filename';
  static const String bucketAlreadyExists = 'bucket_already_exists';

  // Functions Error Codes
  static const String functionNotFound = 'function_not_found';
  static const String functionExecutionFailed = 'function_execution_failed';
  static const String functionTimeout = 'function_timeout';
  static const String invalidFunctionPayload = 'invalid_function_payload';

  // Realtime Error Codes
  static const String connectionError = 'connection_error';
  static const String subscriptionError = 'subscription_error';
  static const String channelError = 'channel_error';
  static const String tooManyConnections = 'too_many_connections';

  // Network/Request Related Errors
  static const String networkError = 'network_error';
  static const String timeoutError = 'timeout_error';
  static const String rateLimited = 'rate_limited';
  static const String serverError = 'server_error';
  static const String unknownError = 'unknown_error';

  // Common pattern fragments to detect in error messages
  static const Map<String, String> errorPatterns = {
    // Auth patterns
    'invalid login credentials': invalidCredentials,
    'email not confirmed': emailNotConfirmed,
    'jwt expired': tokenExpired,
    'invalid token': invalidToken,
    'user not found': userNotFound,
    'already registered': userAlreadyExists,
    'duplicate key value violates unique constraint "users_email_key"': emailTaken,
    'password should be at least': weakPassword,
    
    // Database patterns
    'violates unique constraint': uniqueViolation,
    'violates foreign key constraint': foreignKeyViolation,
    'violates check constraint': checkViolation,
    'violates not-null constraint': notNullViolation,
    'relation .* does not exist': tableNotFound,
    'column .* does not exist': columnNotFound,
    'permission denied': insufficientPrivilege,
    'syntax error': syntaxError,
    'invalid input syntax': invalidParameter,
    
    // Storage patterns
    'no such object': objectNotFound,
    'not found in bucket': objectNotFound,
    'no such bucket': bucketNotFound,
    'not authorized': unauthorized,
    'insufficient storage': insufficientStorage,
    'quota exceeded': quotaExceeded,
    'file too large': fileTooBig,
    'content type not allowed': invalidContentType,
    'invalid file name': invalidFilename,
    
    // Functions patterns
    'function not found': functionNotFound,
    'execution failed': functionExecutionFailed,
    'function timed out': functionTimeout,
    'invalid payload': invalidFunctionPayload,
    
    // Realtime patterns
    'connection error': connectionError,
    'subscription error': subscriptionError,
    'channel error': channelError,
    'too many connections': tooManyConnections,
    
    // Network patterns
    'network error': networkError,
    'timeout': timeoutError,
    'rate limited': rateLimited,
    'server error': serverError,
    'internal server error': serverError,
  };

  /// Ignorable error patterns
  static const List<String> ignorableErrorPatterns = [
    'user cancelled',
    'operation cancelled',
    'abort',
    'user aborted',
    'user rejected',
  ];

  /// Extract a normalized error code from an error message or code
  /// 
  /// This attempts to identify known error patterns in the message
  /// and return the corresponding error code
  static String extractErrorCode(String errorMessage) {
    final lowerMessage = errorMessage.toLowerCase();
    
    // Check for PostgreSQL error codes (format XX000)
    final pgCodeRegex = RegExp(r'[0-9]{2}[0-9A-Z]{3}');
    final pgMatch = pgCodeRegex.firstMatch(errorMessage);
    if (pgMatch != null) {
      return pgMatch.group(0) ?? unknownError;
    }
    
    // Look for known error patterns
    for (final entry in errorPatterns.entries) {
      final pattern = entry.key.toLowerCase();
      if (lowerMessage.contains(pattern)) {
        return entry.value;
      }
    }
    
    // Default to unknown
    return unknownError;
  }
  
  /// Check if an error should be ignored based on its message
  static bool isIgnorable(String errorMessage) {
    final lowerMessage = errorMessage.toLowerCase();
    return ignorableErrorPatterns.any((pattern) => 
      lowerMessage.contains(pattern.toLowerCase())
    );
  }
}