import 'dart:async';

import 'package:flutter/material.dart';

import '../arsync_exception_toolkit.dart';

/// General exception handler for common exception types.
///
/// This handler can process standard Dart/Flutter exceptions and provides
/// appropriate user-friendly messages for each type.
class GeneralExceptionHandler implements ArsyncExceptionHandler {
  @override
  bool canHandle(Object exception) {
    // This is a fallback handler for any type of exception
    return true;
  }

  @override
  ArsyncException handle(Object exception) {
    // Handle specific common exception types
    if (ExceptionUtils.isNetworkConnectivityIssue(exception)) {
      return ArsyncException.network(
        originalException: exception,
      );
    }

    if (exception is FormatException) {
      return ArsyncException.format(
        originalException: exception,
      );
    }

    if (exception is TimeoutException) {
      return ArsyncException.timeout(
        originalException: exception,
      );
    }

    if (exception is AssertionError) {
      return ArsyncException(
        icon: Icons.warning_amber_outlined,
        title: 'Application Error',
        message:
            'An assertion failed in the application. Please report this issue.',
        briefTitle: 'App Error',
        briefMessage: 'Application assertion failed',
        exceptionCode: 'assertion_error',
        originalException: exception,
        technicalDetails: exception.toString(),
      );
    }

    if (exception is StateError) {
      return ArsyncException(
        icon: Icons.sync_problem,
        title: 'State Error',
        message:
            'The application encountered an unexpected state. Please restart the application.',
        briefTitle: 'State Error',
        briefMessage: 'Unexpected application state',
        exceptionCode: 'state_error',
        originalException: exception,
        technicalDetails: exception.toString(),
      );
    }

    if (exception is TypeError) {
      return ArsyncException(
        icon: Icons.bug_report,
        title: 'Type Error',
        message:
            'The application encountered a type error. Please report this issue.',
        briefTitle: 'Type Error',
        briefMessage: 'Application type error',
        exceptionCode: 'type_error',
        originalException: exception,
        technicalDetails: exception.toString(),
      );
    }

    if (exception is ArgumentError) {
      return ArsyncException(
        icon: Icons.warning_amber_outlined,
        title: 'Invalid Argument',
        message:
            'The application received an invalid argument. Please report this issue.',
        briefTitle: 'Invalid Argument',
        briefMessage: 'Application argument error',
        exceptionCode: 'argument_error',
        originalException: exception,
        technicalDetails: exception.toString(),
      );
    }

    if (exception is UnsupportedError) {
      return ArsyncException.unsupported(
        originalException: exception,
      );
    }

    if (exception is ConcurrentModificationError) {
      return ArsyncException(
        icon: Icons.sync_problem,
        title: 'Concurrent Modification',
        message:
            'The application tried to modify data while it was being processed. Please try again.',
        briefTitle: 'Operation Conflict',
        briefMessage: 'Concurrent modification error',
        exceptionCode: 'concurrent_modification_error',
        originalException: exception,
        technicalDetails: exception.toString(),
      );
    }

    if (exception is NoSuchMethodError) {
      return ArsyncException(
        icon: Icons.warning_amber_outlined,
        title: 'Method Error',
        message:
            'The application encountered a method error. Please report this issue.',
        briefTitle: 'Operation Error',
        briefMessage: 'Application method error',
        exceptionCode: 'no_such_method_error',
        originalException: exception,
        technicalDetails: exception.toString(),
      );
    }

    if (exception is RangeError) {
      return ArsyncException(
        icon: Icons.warning_amber_outlined,
        title: 'Range Error',
        message:
            'The application encountered a range error. Please report this issue.',
        briefTitle: 'Range Error',
        briefMessage: 'Application range error',
        exceptionCode: 'range_error',
        originalException: exception,
        technicalDetails: exception.toString(),
      );
    }

    if (ExceptionUtils.isTimeoutIssue(exception)) {
      return ArsyncException.timeout(
        originalException: exception,
      );
    }

    if (ExceptionUtils.isNotFoundIssue(exception)) {
      return ArsyncException.notFound(
        originalException: exception,
      );
    }

    if (ExceptionUtils.isAuthenticationIssue(exception)) {
      return ArsyncException.authentication(
        originalException: exception,
      );
    }

    if (ExceptionUtils.isServerIssue(exception)) {
      return ArsyncException.server(
        originalException: exception,
      );
    }

    if (ExceptionUtils.isFormatIssue(exception)) {
      return ArsyncException.format(
        originalException: exception,
      );
    }

    if (ExceptionUtils.isUnsupportedIssue(exception)) {
      return ArsyncException.unsupported(
        originalException: exception,
      );
    }

    // Default unknown exception
    return ArsyncException.generic(
      originalException: exception,
    );
  }

  @override
  int get priority => -999; // Lowest priority, should be tried last
}
