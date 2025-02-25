import 'package:arsync_exception_toolkit/arsync_exception_toolkit.dart';
import 'package:flutter/material.dart';

/// Extensions for the AppException class to provide additional functionality.
extension ArsyncExceptionExtensions on ArsyncException {
  /// Returns a simplified variant of the exception suitable for user display.
  ArsyncException simplified() {
    return copyWith(message: briefMessage);
  }

  /// Returns a variant with a different icon.
  ArsyncException withIcon(IconData newIcon) {
    return copyWith(icon: newIcon);
  }

  /// Returns a variant with a different title.
  ArsyncException withTitle(String newTitle) {
    return copyWith(title: newTitle);
  }

  /// Returns a variant with a different message.
  ArsyncException withMessage(String newMessage) {
    return copyWith(message: newMessage);
  }

  /// Returns a variant with a different brief title.
  ArsyncException withBriefTitle(String newBriefTitle) {
    return copyWith(briefTitle: newBriefTitle);
  }

  /// Returns a variant with a different brief message.
  ArsyncException withBriefMessage(String newBriefMessage) {
    return copyWith(briefMessage: newBriefMessage);
  }
}
