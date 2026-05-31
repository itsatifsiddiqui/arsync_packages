import 'package:arsync_exception_toolkit/arsync_exception_toolkit.dart';

/// Typed error codes for generic Firebase Core exceptions.
///
/// Each value holds the stable `id` string that equals the original
/// hardcoded `exceptionCode` literal verbatim.
enum FirebaseCoreCode implements ArsyncExceptionCode {
  networkRequestFailed('firebase_core_network_request_failed'),
  timeout('firebase_core_timeout'),
  appNotAuthorized('firebase_core_app_not_authorized'),
  noSuchProvider('firebase_core_no_such_provider'),
  operationNotAllowed('firebase_core_operation_not_allowed'),
  internalError('firebase_core_internal_error'),
  invalidApiKey('firebase_core_invalid_api_key'),
  appNotInstalled('firebase_core_app_not_installed'),
  unknown('firebase_core_unknown'),
  ;

  const FirebaseCoreCode(this.id);

  @override
  final String id;
}
