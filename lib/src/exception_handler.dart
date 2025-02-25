import 'arsync_exception.dart';

/// Base interface for all exception handlers.
///
/// Implement this interface to create handlers for specific types of exceptions.
/// Each handler is responsible for converting raw exceptions into structured
/// AppException objects that can be displayed to users.
abstract class ArsyncExceptionHandler {
  /// Determines if this handler can handle the given exception.
  ///
  /// Returns true if this handler is appropriate for the exception.
  bool canHandle(Object exception);

  /// Maps the exception to an AppException.
  ///
  /// This method converts a raw exception into a structured AppException with
  /// user-friendly information.
  ArsyncException handle(Object exception);

  /// Optional priority level for this handler (higher value = higher priority).
  ///
  /// Used by ExceptionMapper to determine which handler to use when multiple
  /// handlers can handle an exception.
  int get priority => 0;
}
