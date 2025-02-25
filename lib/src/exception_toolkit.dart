import '../arsync_exception_toolkit.dart';
import 'exception_mapper.dart';

/// Customization callback for modifying exceptions before they're returned.
typedef ExceptionModifier = ArsyncException Function(
  ArsyncException exception,
  Object originalException,
);

/// Central service for exception handling throughout the application.
///
/// This class provides the main API for the exception handling system,
/// coordinating between different components and providing customization options.
class ArsyncExceptionToolkit {
  /// The mapper to convert raw exceptions to ArsyncException objects
  final ArsyncExceptionMapper _exceptionMapper;

  /// Custom modifiers for specific exception codes
  final Map<String, ExceptionModifier> _exceptionModifiers = {};

  /// Strings that, if found in exception messages, will be considered ignorable
  final List<String> _ignorableExceptions;

  /// Create an ExceptionService with configuration options.
  ///
  /// [exceptionMapper] - The mapper to use for converting exceptions to AppException objects.
  /// [ignorableExceptions] - Strings that, if found in exception messages, will be ignored.
  ArsyncExceptionToolkit({
    List<ArsyncExceptionHandler> handlers = const [],
    bool sortByPriority = true,
    List<String>? ignorableExceptions,
  })  : _exceptionMapper = ArsyncExceptionMapper(
          handlers: handlers,
          sortByPriority: sortByPriority,
        ),
        _ignorableExceptions = ignorableExceptions ?? arsyncIgnorableExceptions;

  /// Handle an exception and return an AppException.
  ///
  /// [exception] - The exception to handle.
  /// [ignoreMatching] - If true, exceptions matching ignorable patterns return a cancelled exception.
  ArsyncException handleException(
    Object exception, {
    bool ignoreMatching = true,
  }) {
    if (ignoreMatching && shouldIgnoreException(exception)) {
      // Return a ignored exception for ignored exceptions
      return ArsyncException.ignored(
        technicalDetails: exception.toString(),
        originalException: exception,
      );
    }

    // Map the exception to an AppException
    ArsyncException appException = _exceptionMapper.mapException(exception);

    // Apply any registered modifiers for the exception code
    if (appException.exceptionCode != null &&
        _exceptionModifiers.containsKey(appException.exceptionCode)) {
      appException = _exceptionModifiers[appException.exceptionCode]!(
          appException, exception);
    }

    return appException;
  }

  /// Access the exception mapper to customize handlers.
  ArsyncExceptionMapper get exceptionMapper => _exceptionMapper;

  /// Register a custom modifier for a specific exception code.
  ///
  /// [exceptionCode] - The exception code to modify.
  /// [modifier] - Function that transforms the exception.
  void registerExceptionModifier(
    String exceptionCode,
    ExceptionModifier modifier,
  ) {
    _exceptionModifiers[exceptionCode] = modifier;
  }

  /// Remove a custom modifier for a specific exception code.
  ///
  /// [exceptionCode] - The exception code to remove the modifier for.
  void removeExceptionModifier(String exceptionCode) {
    _exceptionModifiers.remove(exceptionCode);
  }

  /// Add a string to the list of ignorable exceptions.
  ///
  /// [exceptionPattern] - String pattern to match in exception messages.
  void addIgnorableException(String exceptionPattern) {
    if (!_ignorableExceptions.contains(exceptionPattern)) {
      _ignorableExceptions.add(exceptionPattern);
    }
  }

  /// Remove a string from the list of ignorable exceptions.
  ///
  /// [exceptionPattern] - Pattern to remove from the ignorable list.
  void removeIgnorableException(String exceptionPattern) {
    _ignorableExceptions.remove(exceptionPattern);
  }

  /// Check if the exception should be ignored.
  ///
  /// Returns true if the exception message contains any ignorable patterns.
  bool shouldIgnoreException(Object exception) {
    final exceptionString = exception.toString().toLowerCase();

    return _ignorableExceptions
        .any((term) => exceptionString.contains(term.toLowerCase()));
  }

  /// Check if it's a network-related exception.
  ///
  /// Returns true if the exception appears to be related to network issues.
  bool isNetworkException(Object exception) {
    return ExceptionUtils.isNetworkConnectivityIssue(exception);
  }

  /// Default list of exception substrings that indicate the exception should be ignored.
  static const List<String> arsyncIgnorableExceptions = [
    'web-context-cancelled',
    'cancelled',
    'user cancelled',
    'sign_in_with_apple.authorization',
    'user denied the dialog',
    'operation was cancelled',
  ];
}
