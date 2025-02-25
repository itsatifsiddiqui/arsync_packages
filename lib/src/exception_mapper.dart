import 'arsync_exception.dart';
import 'exception_handler.dart';
import 'general_exception_handler.dart';

/// Maps exceptions to ArsyncException objects using appropriate handlers.
///
/// This class manages a collection of exception handlers and selects the
/// appropriate handler to convert raw exceptions into ArsyncException objects.
class ArsyncExceptionMapper {
  /// List of registered exception handlers
  final List<ArsyncExceptionHandler> _handlers;

  /// Whether to sort handlers by priority
  final bool sortByPriority;

  /// Create an ExceptionMapper with configuration options.
  ///
  /// [handlers] - List of exception handlers to use. If null, only GeneralExceptionHandler is used.
  /// [sortByPriority] - If true, handlers will be sorted by priority before use.
  ArsyncExceptionMapper({
    List<ArsyncExceptionHandler> handlers = const [],
    this.sortByPriority = true,
  }) : _handlers = [
          ...handlers,
          GeneralExceptionHandler(),
        ] {
    if (sortByPriority) {
      _sortHandlersByPriority();
    }
  }

  /// Maps an exception to an ArsyncException using the appropriate handler.
  ///
  /// This method iterates through registered handlers and uses the first one
  /// that can handle the given exception.
  ///
  /// [exception] - The exception to map.
  /// [fallbackMessage] - Optional message to use if no handler can process the exception.
  ArsyncException mapException(Object exception, {String? fallbackMessage}) {
    // Find the first handler that can handle this exception
    for (final handler in _handlers) {
      if (handler.canHandle(exception)) {
        return handler.handle(exception);
      }
    }

    // This should never happen with GeneralExceptionHandler in place,
    // but just in case, return a default exception
    return ArsyncException.generic(
      message: fallbackMessage ??
          'An unexpected error occurred: ${exception.toString()}',
      technicalDetails: exception.toString(),
      originalException: exception,
    );
  }

  /// Sort handlers by priority (highest first).
  void _sortHandlersByPriority() {
    _handlers.sort((a, b) => b.priority.compareTo(a.priority));
  }

  /// Get all registered handlers.
  List<ArsyncExceptionHandler> get handlers => List.unmodifiable(_handlers);
}
