/// Constants for Firebase error codes
class FirebaseErrorCodes {
  // Firebase Auth Error Codes
  static const String userNotFound = 'user-not-found';
  static const String wrongPassword = 'wrong-password';
  static const String emailAlreadyInUse = 'email-already-in-use';
  static const String invalidEmail = 'invalid-email';
  static const String weakPassword = 'weak-password';
  static const String invalidVerificationCode = 'invalid-verification-code';
  static const String invalidVerificationId = 'invalid-verification-id';
  static const String operationNotAllowed = 'operation-not-allowed';
  static const String userDisabled = 'user-disabled';
  static const String providerAlreadyLinked = 'provider-already-linked';
  static const String invalidCredential = 'invalid-credential';
  static const String credentialAlreadyInUse = 'credential-already-in-use';
  static const String accountExistsWithDifferentCredential =
      'account-exists-with-different-credential';
  static const String tooManyRequests = 'too-many-requests';
  static const String requiresRecentLogin = 'requires-recent-login';
  static const String webContextCancelled = 'web-context-cancelled';
  static const String popupClosedByUser = 'popup-closed-by-user';
  static const String userCancelled = 'user-cancelled';

  // Firestore Error Codes
  static const String permissionDenied = 'permission-denied';
  static const String unavailable = 'unavailable';
  static const String notFound = 'not-found';
  static const String alreadyExists = 'already-exists';
  static const String dataLoss = 'data-loss';
  static const String invalidArgument = 'invalid-argument';
  static const String resourceExhausted = 'resource-exhausted';
  static const String failedPrecondition = 'failed-precondition';
  static const String unimplemented = 'unimplemented';
  static const String deadlineExceeded = 'deadline-exceeded';
  static const String outOfRange = 'out-of-range';
  static const String unauthenticated = 'unauthenticated';
  static const String aborted = 'aborted';

  // Storage Error Codes
  static const String objectNotFound = 'object-not-found';
  static const String unauthorized = 'unauthorized';
  static const String quotaExceeded = 'quota-exceeded';
  static const String retryLimitExceeded = 'retry-limit-exceeded';
  static const String nonMatchingChecksum = 'non-matching-checksum';
  static const String downloadSizeExceeded = 'download-size-exceeded';
  static const String cancelled = 'cancelled';
  static const String invalidEventName = 'invalid-event-name';
  static const String invalidUrl = 'invalid-url';
  static const String invalidDeleteTime = 'invalid-delete-time';
  static const String bucketNotFound = 'bucket-not-found';
  static const String projectNotFound = 'project-not-found';
  static const String invalidChecksum = 'invalid-checksum';
  static const String invalidState = 'invalid-state';

  // Network Error Codes
  static const String networkRequestFailed = 'network-request-failed';
  static const String timeout = 'timeout';

  // General Error Codes
  static const String internalError = 'internal-error';
  static const String unknown = 'unknown';

  // Additional error codes for Firebase Core
  static const String appNotAuthorized = 'app-not-authorized';
  static const String noSuchProvider = 'no-such-provider';
  static const String invalidApiKey = 'invalid-api-key';
  static const String appNotInstalled = 'app-not-installed';

  // Ignorable Exceptions
  static const List<String> ignorableErrorCodes = [
    webContextCancelled,
    cancelled,
    popupClosedByUser,
    userCancelled,
  ];

  /// Check if the given error code is ignorable
  static bool isIgnorable(String code) {
    return ignorableErrorCodes.contains(code);
  }
}