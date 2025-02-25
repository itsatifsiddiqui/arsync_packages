/// Supabase error handlers for the Arsync Exception Toolkit
/// 
/// This package provides specialized error handlers for various Supabase services
/// that integrate with the Arsync Exception Toolkit.
library arsync_supabase_errors_handler;

// Core handlers for Supabase services
export 'src/supabase_auth_handler.dart';
export 'src/supabase_database_handler.dart';
export 'src/supabase_storage_handler.dart';
export 'src/supabase_functions_handler.dart';
export 'src/supabase_realtime_handler.dart';

// Utilities and extensions
export 'src/supabase_error_codes.dart';
export 'src/toolkit_extensions.dart';

// All-in-one handler
export 'src/supabase_errors_handler.dart';