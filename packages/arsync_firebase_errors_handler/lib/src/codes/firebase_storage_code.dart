import 'package:arsync_exception_toolkit/arsync_exception_toolkit.dart';

/// Typed error codes for Firebase Storage exceptions.
///
/// Each value holds the stable `id` string that equals the original
/// hardcoded `exceptionCode` literal verbatim.
enum FirebaseStorageCode implements ArsyncExceptionCode {
  objectNotFound('firebase_storage_object_not_found'),
  unauthorized('firebase_storage_unauthorized'),
  quotaExceeded('firebase_storage_quota_exceeded'),
  retryLimitExceeded('firebase_storage_retry_limit_exceeded'),
  nonMatchingChecksum('firebase_storage_non_matching_checksum'),
  downloadSizeExceeded('firebase_storage_download_size_exceeded'),
  cancelled('firebase_storage_cancelled'),
  invalidUrl('firebase_storage_invalid_url'),
  invalidChecksum('firebase_storage_invalid_checksum'),
  bucketNotFound('firebase_storage_bucket_not_found'),
  projectNotFound('firebase_storage_project_not_found'),
  unauthenticated('firebase_storage_unauthenticated'),
  networkRequestFailed('firebase_storage_network_request_failed'),
  unknown('firebase_storage_unknown'),
  ;

  const FirebaseStorageCode(this.id);

  @override
  final String id;
}
