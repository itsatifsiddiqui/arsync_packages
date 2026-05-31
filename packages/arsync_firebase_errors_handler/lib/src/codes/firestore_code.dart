import 'package:arsync_exception_toolkit/arsync_exception_toolkit.dart';

/// Typed error codes for Firestore exceptions.
///
/// Each value's [id] is the stable string previously used as the
/// hardcoded `exceptionCode` literal for that case.
enum FirestoreCode implements ArsyncExceptionCode {
  permissionDenied('firestore_permission_denied'),
  unavailable('firestore_unavailable'),
  notFound('firestore_not_found'),
  alreadyExists('firestore_already_exists'),
  dataLoss('firestore_data_loss'),
  invalidArgument('firestore_invalid_argument'),
  resourceExhausted('firestore_resource_exhausted'),
  failedPrecondition('firestore_failed_precondition'),
  aborted('firestore_aborted'),
  deadlineExceeded('firestore_deadline_exceeded'),
  outOfRange('firestore_out_of_range'),
  unimplemented('firestore_unimplemented'),
  unauthenticated('firestore_unauthenticated'),
  networkRequestFailed('firestore_network_request_failed'),
  cancelled('firestore_cancelled'),
  unknown('firestore_unknown'),
  ;

  const FirestoreCode(this.id);

  @override
  final String id;
}
