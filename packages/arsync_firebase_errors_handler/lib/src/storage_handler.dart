import 'package:arsync_exception_toolkit/arsync_exception_toolkit.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart'
    show FirebaseException;
import 'package:flutter/material.dart';

import 'codes/firebase_storage_code.dart';
import 'firebase_error_codes.dart';

/// Handler specifically for Firebase Storage exceptions
class FirebaseStorageHandler implements ArsyncExceptionHandler {
  /// Custom error exceptions to override the defaults
  final Map<String, ArsyncException>? customExceptions;

  /// Priority level for this handler (higher means it's tried earlier)
  final int _priority;

  /// Create a Firebase Storage error handler
  ///
  /// [customExceptions] - Optional map to override default error exceptions
  /// [priority] - Priority level for this handler (higher = higher priority)
  FirebaseStorageHandler({
    this.customExceptions,
    int priority = 16,
  }) : _priority = priority;

  @override
  bool canHandle(Object exception) {
    return exception is FirebaseException &&
        exception.plugin == 'firebase_storage';
  }

  @override
  ArsyncException handle(Object exception) {
    final storageException = exception as FirebaseException;
    final code = storageException.code;

    // Handle ignorable exceptions
    if (FirebaseErrorCodes.isIgnorable(code)) {
      return ArsyncException.ignored(
        originalException: exception,
        technicalDetails:
            'Firebase Storage: $code - ${storageException.message}',
      );
    }

    // Use custom error exceptions if provided and the code exists
    if (customExceptions != null && customExceptions!.containsKey(code)) {
      // Return a copy with the original exception and technical details
      return customExceptions![code]!.copyWith(
        originalException: exception,
        technicalDetails:
            'Firebase Storage: $code - ${storageException.message}',
      );
    }

    // Use default error exceptions
    if (_defaultErrorMap.containsKey(code)) {
      // Return a copy with the original exception and technical details
      return _defaultErrorMap[code]!.copyWith(
        originalException: exception,
        technicalDetails:
            'Firebase Storage: $code - ${storageException.message}',
      );
    }

    // Default error for unknown codes
    return ArsyncException(
      icon: Icons.cloud_outlined,
      title: 'Storage Error',
      message:
          storageException.message ?? 'An unexpected storage error occurred',
      briefTitle: 'Storage Error',
      briefMessage: 'Storage operation failed',
      exceptionCode: RawArsyncExceptionCode('firebase_storage_$code'),
      originalException: exception,
      technicalDetails: 'Firebase Storage: $code - ${storageException.message}',
    );
  }

  @override
  int get priority => _priority;

  /// Create a new instance with custom error exceptions
  FirebaseStorageHandler withCustomExceptions(
      Map<String, ArsyncException> customExceptions) {
    // Start with a copy of the default map
    final Map<String, ArsyncException> mergedExceptions =
        Map.from(_defaultErrorMap);

    // Override with any custom exceptions
    mergedExceptions.addAll(customExceptions);

    return FirebaseStorageHandler(
      customExceptions: mergedExceptions,
      priority: priority,
    );
  }

  /// Default error exceptions for Firebase Storage errors
  static final Map<String, ArsyncException> _defaultErrorMap = {
    FirebaseErrorCodes.objectNotFound: ArsyncException(
      icon: Icons.find_replace,
      title: 'File Missing',
      message:
          'The file you\'re trying to access cannot be found. It may have been moved or deleted.',
      briefTitle: 'File Not Found',
      briefMessage: 'File not found',
      exceptionCode: FirebaseStorageCode.objectNotFound,
    ),
    FirebaseErrorCodes.unauthorized: ArsyncException(
      icon: Icons.no_accounts,
      title: 'Access Denied',
      message:
          'You don\'t have permission to access this file. Please request access if needed.',
      briefTitle: 'No Access',
      briefMessage: 'No access',
      exceptionCode: FirebaseStorageCode.unauthorized,
    ),
    FirebaseErrorCodes.quotaExceeded: ArsyncException(
      icon: Icons.storage,
      title: 'Storage Limit Reached',
      message:
          'Your storage quota has been exceeded. Please upgrade your plan or delete some files to free up space.',
      briefTitle: 'Storage Full',
      briefMessage: 'Storage quota exceeded',
      exceptionCode: FirebaseStorageCode.quotaExceeded,
    ),
    FirebaseErrorCodes.retryLimitExceeded: ArsyncException(
      icon: Icons.replay_circle_filled,
      title: 'Too Many Retries',
      message:
          'The operation has been attempted too many times. Please try again later.',
      briefTitle: 'Retry Limit',
      briefMessage: 'Too many retries',
      exceptionCode: FirebaseStorageCode.retryLimitExceeded,
    ),
    FirebaseErrorCodes.nonMatchingChecksum: ArsyncException(
      icon: Icons.error_outline,
      title: 'File Integrity Error',
      message:
          'The file\'s checksum doesn\'t match. The uploaded file might be corrupted.',
      briefTitle: 'Integrity Error',
      briefMessage: 'File integrity error',
      exceptionCode: FirebaseStorageCode.nonMatchingChecksum,
    ),
    FirebaseErrorCodes.downloadSizeExceeded: ArsyncException(
      icon: Icons.file_download_off,
      title: 'File Too Large',
      message: 'The file is too large to download. Please try a smaller file.',
      briefTitle: 'File Too Large',
      briefMessage: 'Download size exceeded',
      exceptionCode: FirebaseStorageCode.downloadSizeExceeded,
    ),
    FirebaseErrorCodes.cancelled: ArsyncException(
      icon: Icons.cancel_outlined,
      title: 'Operation Cancelled',
      message: 'The storage operation was cancelled.',
      briefTitle: 'Cancelled',
      briefMessage: 'Operation cancelled',
      exceptionCode: FirebaseStorageCode.cancelled,
    ),
    FirebaseErrorCodes.invalidUrl: ArsyncException(
      icon: Icons.link_off,
      title: 'Invalid URL',
      message: 'The provided URL is invalid or malformed.',
      briefTitle: 'Invalid URL',
      briefMessage: 'Invalid URL',
      exceptionCode: FirebaseStorageCode.invalidUrl,
    ),
    FirebaseErrorCodes.invalidChecksum: ArsyncException(
      icon: Icons.error_outline,
      title: 'Checksum Error',
      message:
          'The file has an invalid checksum. Please try uploading it again.',
      briefTitle: 'Checksum Error',
      briefMessage: 'Invalid checksum',
      exceptionCode: FirebaseStorageCode.invalidChecksum,
    ),
    FirebaseErrorCodes.bucketNotFound: ArsyncException(
      icon: Icons.folder_off,
      title: 'Storage Bucket Not Found',
      message:
          'The storage bucket does not exist. Please check your configuration.',
      briefTitle: 'Bucket Not Found',
      briefMessage: 'Storage bucket not found',
      exceptionCode: FirebaseStorageCode.bucketNotFound,
    ),
    FirebaseErrorCodes.projectNotFound: ArsyncException(
      icon: Icons.folder_off,
      title: 'Project Not Found',
      message:
          'The Firebase project could not be found. Please check your configuration.',
      briefTitle: 'Project Not Found',
      briefMessage: 'Project not found',
      exceptionCode: FirebaseStorageCode.projectNotFound,
    ),
    FirebaseErrorCodes.unauthenticated: ArsyncException(
      icon: Icons.lock_outline,
      title: 'Authentication Required',
      message: 'You need to be signed in to perform this action.',
      briefTitle: 'Sign In Required',
      briefMessage: 'Authentication required',
      exceptionCode: FirebaseStorageCode.unauthenticated,
    ),
    FirebaseErrorCodes.networkRequestFailed: ArsyncException(
      icon: Icons.wifi_off,
      title: 'Connection Error',
      message:
          'Unable to connect to our servers. Please check your internet connection and try again.',
      briefTitle: 'No Connection',
      briefMessage: 'Network error',
      exceptionCode: FirebaseStorageCode.networkRequestFailed,
    ),
    FirebaseErrorCodes.unknown: ArsyncException(
      icon: Icons.help_outline,
      title: 'Unexpected Storage Error',
      message:
          'An unexpected error occurred with file storage. Please try again or contact support if the problem persists.',
      briefTitle: 'Unknown Error',
      briefMessage: 'Unknown error',
      exceptionCode: FirebaseStorageCode.unknown,
    ),
  };
}
