import 'package:arsync_exception_toolkit/arsync_exception_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:supabase/supabase.dart';

import 'supabase_error_codes.dart';

/// Handler specifically for Supabase Storage exceptions
class SupabaseStorageHandler implements ArsyncExceptionHandler {
  /// Custom error exceptions to override the defaults
  final Map<String, ArsyncException>? customExceptions;

  /// Priority level for this handler (higher means it's tried earlier)
  final int _priority;

  /// Create a Supabase Storage error handler
  ///
  /// [customExceptions] - Optional map to override default error exceptions
  /// [priority] - Priority level for this handler (higher = higher priority)
  SupabaseStorageHandler({
    this.customExceptions,
    int priority = 16,
  }) : _priority = priority;

  @override
  bool canHandle(Object exception) {
    if (exception is StorageException) {
      return true;
    }

    // Check regular exceptions with storage-related messages
    final exceptionStr = exception.toString().toLowerCase();
    return exceptionStr.contains('storage/') ||
        exceptionStr.contains('bucket') ||
        exceptionStr.contains('object not found') ||
        exceptionStr.contains('file too large');
  }

  @override
  ArsyncException handle(Object exception) {
    String code = SupabaseErrorCodes.unknownError;
    String message = 'A storage error occurred';

    // Extract error details depending on exception type
    if (exception is StorageException) {
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
        technicalDetails: 'Supabase Storage: $code - $message',
      );
    }

    // Use custom error exceptions if provided and the code exists
    if (customExceptions != null && customExceptions!.containsKey(code)) {
      return customExceptions![code]!.copyWith(
        originalException: exception,
        technicalDetails: 'Supabase Storage: $code - $message',
      );
    }

    // Use default error exceptions
    if (_defaultErrorMap.containsKey(code)) {
      return _defaultErrorMap[code]!.copyWith(
        originalException: exception,
        technicalDetails: 'Supabase Storage: $code - $message',
      );
    }

    // Default error for unknown codes
    return ArsyncException(
      icon: Icons.cloud_outlined,
      title: 'Storage Error',
      message: message,
      briefTitle: 'Storage Error',
      briefMessage: 'Storage operation failed',
      exceptionCode: 'supabase_storage_$code',
      originalException: exception,
      technicalDetails: 'Supabase Storage: $code - $message',
    );
  }

  /// Extract an error code from the exception
  String _extractErrorCode(Object exception) {
    if (exception is StorageException) {
      // If we have an error code, use it
      if (exception.statusCode != null) {
        // Map HTTP status codes to error codes
        switch (exception.statusCode) {
          case "404":
            return SupabaseErrorCodes.objectNotFound;
          case "403":
            return SupabaseErrorCodes.unauthorized;
          case "507":
            return SupabaseErrorCodes.insufficientStorage;
          case "413":
            return SupabaseErrorCodes.fileTooBig;
          case "415":
            return SupabaseErrorCodes.invalidContentType;
          case "400":
            return SupabaseErrorCodes.invalidFilename;
          case "409":
            return SupabaseErrorCodes.bucketAlreadyExists;
          case "429":
            return SupabaseErrorCodes.rateLimited;
          case "500":
            return SupabaseErrorCodes.serverError;
          case "503":
            return SupabaseErrorCodes.serverError;
          default:
            break;
        }
      }

      // Try to extract from message
      return SupabaseErrorCodes.extractErrorCode(exception.message);
    } else {
      // For general exceptions, use the string representation
      return SupabaseErrorCodes.extractErrorCode(exception.toString());
    }
  }

  @override
  int get priority => _priority;

  /// Create a new instance with custom error exceptions
  SupabaseStorageHandler withCustomExceptions(
      Map<String, ArsyncException> customExceptions) {
    // Start with a copy of the default map
    final Map<String, ArsyncException> mergedExceptions =
        Map.from(_defaultErrorMap);

    // Override with any custom exceptions
    mergedExceptions.addAll(customExceptions);

    return SupabaseStorageHandler(
      customExceptions: mergedExceptions,
      priority: priority,
    );
  }

  /// Default error exceptions for Supabase Storage errors
  static final Map<String, ArsyncException> _defaultErrorMap = {
    SupabaseErrorCodes.objectNotFound: ArsyncException(
      icon: Icons.find_replace,
      title: 'File Not Found',
      message:
          'The file you\'re looking for cannot be found. It may have been moved or deleted.',
      briefTitle: 'File Missing',
      briefMessage: 'File not found',
      exceptionCode: 'supabase_storage_object_not_found',
    ),
    SupabaseErrorCodes.bucketNotFound: ArsyncException(
      icon: Icons.folder_off,
      title: 'Storage Bucket Not Found',
      message:
          'The storage bucket you\'re trying to access doesn\'t exist. This may be a configuration issue.',
      briefTitle: 'Bucket Missing',
      briefMessage: 'Storage bucket not found',
      exceptionCode: 'supabase_storage_bucket_not_found',
    ),
    SupabaseErrorCodes.unauthorized: ArsyncException(
      icon: Icons.no_accounts,
      title: 'Access Denied',
      message:
          'You don\'t have permission to access this file or storage location.',
      briefTitle: 'No Access',
      briefMessage: 'Permission denied',
      exceptionCode: 'supabase_storage_unauthorized',
    ),
    SupabaseErrorCodes.insufficientStorage: ArsyncException(
      icon: Icons.sd_card_alert,
      title: 'Storage Space Full',
      message:
          'There isn\'t enough storage space available. Please free up some space or contact the administrator.',
      briefTitle: 'Storage Full',
      briefMessage: 'Not enough storage space',
      exceptionCode: 'supabase_storage_insufficient_storage',
    ),
    SupabaseErrorCodes.quotaExceeded: ArsyncException(
      icon: Icons.storage,
      title: 'Storage Limit Reached',
      message:
          'You\'ve reached your storage quota limit. Please delete some files or upgrade your plan.',
      briefTitle: 'Quota Exceeded',
      briefMessage: 'Storage limit reached',
      exceptionCode: 'supabase_storage_quota_exceeded',
    ),
    SupabaseErrorCodes.fileTooBig: ArsyncException(
      icon: Icons.file_copy,
      title: 'File Too Large',
      message:
          'The file you\'re trying to upload is too large. Please try a smaller file.',
      briefTitle: 'File Too Large',
      briefMessage: 'File size exceeds limit',
      exceptionCode: 'supabase_storage_file_too_big',
    ),
    SupabaseErrorCodes.invalidContentType: ArsyncException(
      icon: Icons.file_present,
      title: 'Unsupported File Type',
      message:
          'This file type is not supported. Please try a different file format.',
      briefTitle: 'Invalid File Type',
      briefMessage: 'Unsupported file type',
      exceptionCode: 'supabase_storage_invalid_content_type',
    ),
    SupabaseErrorCodes.invalidFilename: ArsyncException(
      icon: Icons.text_snippet,
      title: 'Invalid Filename',
      message:
          'The filename contains invalid characters or is in an invalid format.',
      briefTitle: 'Invalid Filename',
      briefMessage: 'Invalid filename',
      exceptionCode: 'supabase_storage_invalid_filename',
    ),
    SupabaseErrorCodes.bucketAlreadyExists: ArsyncException(
      icon: Icons.folder_copy,
      title: 'Bucket Already Exists',
      message:
          'A storage bucket with this name already exists. Please use a different name.',
      briefTitle: 'Bucket Exists',
      briefMessage: 'Bucket already exists',
      exceptionCode: 'supabase_storage_bucket_already_exists',
    ),
    SupabaseErrorCodes.networkError: ArsyncException(
      icon: Icons.wifi_off,
      title: 'Network Error',
      message:
          'Unable to connect to the storage service. Please check your internet connection and try again.',
      briefTitle: 'No Connection',
      briefMessage: 'Network error',
      exceptionCode: 'supabase_storage_network_error',
    ),
    SupabaseErrorCodes.timeoutError: ArsyncException(
      icon: Icons.timer_off,
      title: 'Upload Timeout',
      message:
          'The file upload timed out. Please check your connection and try again, possibly with a smaller file.',
      briefTitle: 'Timeout',
      briefMessage: 'Upload timed out',
      exceptionCode: 'supabase_storage_timeout_error',
    ),
    SupabaseErrorCodes.rateLimited: ArsyncException(
      icon: Icons.speed,
      title: 'Too Many Requests',
      message:
          'You\'ve made too many storage requests. Please wait a few moments and try again.',
      briefTitle: 'Rate Limited',
      briefMessage: 'Too many requests',
      exceptionCode: 'supabase_storage_rate_limited',
    ),
    SupabaseErrorCodes.serverError: ArsyncException(
      icon: Icons.cloud_off,
      title: 'Storage Server Error',
      message:
          'The storage server encountered an error. Please try again later.',
      briefTitle: 'Server Error',
      briefMessage: 'Storage server error',
      exceptionCode: 'supabase_storage_server_error',
    ),
    SupabaseErrorCodes.unknownError: ArsyncException(
      icon: Icons.help_outline,
      title: 'Storage Error',
      message:
          'An unexpected storage error occurred. Please try again or contact support.',
      briefTitle: 'Storage Error',
      briefMessage: 'Storage operation failed',
      exceptionCode: 'supabase_storage_unknown_error',
    ),
  };
}
