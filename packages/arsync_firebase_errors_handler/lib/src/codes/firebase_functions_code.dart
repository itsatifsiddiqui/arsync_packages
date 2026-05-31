import 'package:arsync_exception_toolkit/arsync_exception_toolkit.dart';

/// Typed error codes for Firebase Cloud Functions exceptions.
///
/// Each value holds the stable `id` string that equals the original
/// hardcoded `exceptionCode` literal verbatim.
enum FirebaseFunctionsCode implements ArsyncExceptionCode {
  invalidArgument('firebase_functions_invalid_argument'),
  notFound('firebase_functions_not_found'),
  permissionDenied('firebase_functions_permission_denied'),
  unauthenticated('firebase_functions_unauthenticated'),
  resourceExhausted('firebase_functions_resource_exhausted'),
  failedPrecondition('firebase_functions_failed_precondition'),
  aborted('firebase_functions_aborted'),
  deadlineExceeded('firebase_functions_deadline_exceeded'),
  unavailable('firebase_functions_unavailable'),
  internalError('firebase_functions_internal_error'),
  unimplemented('firebase_functions_unimplemented'),
  cancelled('firebase_functions_cancelled'),
  networkRequestFailed('firebase_functions_network_request_failed'),
  unknown('firebase_functions_unknown'),
  ;

  const FirebaseFunctionsCode(this.id);

  @override
  final String id;
}
