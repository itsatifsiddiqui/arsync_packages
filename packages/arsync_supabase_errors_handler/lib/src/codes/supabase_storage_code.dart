import 'package:arsync_exception_toolkit/arsync_exception_toolkit.dart';

/// Typed error codes for Supabase Storage errors.
///
/// Each value's [id] equals the stable `exceptionCode` string used by the
/// Supabase Storage handler.
enum SupabaseStorageCode implements ArsyncExceptionCode {
  objectNotFound('supabase_storage_object_not_found'),
  bucketNotFound('supabase_storage_bucket_not_found'),
  unauthorized('supabase_storage_unauthorized'),
  insufficientStorage('supabase_storage_insufficient_storage'),
  quotaExceeded('supabase_storage_quota_exceeded'),
  fileTooBig('supabase_storage_file_too_big'),
  invalidContentType('supabase_storage_invalid_content_type'),
  invalidFilename('supabase_storage_invalid_filename'),
  bucketAlreadyExists('supabase_storage_bucket_already_exists'),
  networkError('supabase_storage_network_error'),
  timeoutError('supabase_storage_timeout_error'),
  rateLimited('supabase_storage_rate_limited'),
  serverError('supabase_storage_server_error'),
  unknownError('supabase_storage_unknown_error'),
  ;

  const SupabaseStorageCode(this.id);

  @override
  final String id;
}
