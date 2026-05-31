/// Firebase error handlers for the Arsync Exception Toolkit
///
/// This package provides specialized error handlers for various Firebase services
/// that integrate with the Arsync Exception Toolkit.
library;

// Typed error codes
export 'src/codes/firebase_auth_code.dart';
export 'src/codes/firebase_core_code.dart';
export 'src/codes/firebase_functions_code.dart';
export 'src/codes/firebase_storage_code.dart';
export 'src/codes/firestore_code.dart';
// Core handlers for Firebase services
export 'src/firebase_auth_handler.dart';
export 'src/firebase_core_handler.dart';
// Utilities and extensions
export 'src/firebase_error_codes.dart';
// All-in-one handler
export 'src/firebase_errors_handler.dart';
export 'src/firestore_handler.dart';
export 'src/functions_handler.dart';
export 'src/storage_handler.dart';
