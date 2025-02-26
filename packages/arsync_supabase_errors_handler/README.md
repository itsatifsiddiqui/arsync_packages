# Arsync Supabase Errors Handler

A specialized package for handling Supabase-specific errors with the [Arsync Exception Toolkit](https://pub.dev/packages/arsync_exception_toolkit).

[![pub package](https://img.shields.io/pub/v/arsync_supabase_errors_handler.svg)](https://pub.dev/packages/arsync_supabase_errors_handler)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

## Features

- ✨ **Specialized Supabase Error Handling**: Human-friendly error messages for all Supabase services
- 🔍 **Service-Specific Handlers**: Dedicated handlers for Auth, Database, Storage, Functions, and Realtime
- 🎯 **PostgreSQL Error Code Support**: Detailed handling for database error codes
- 🚀 **Easy Integration**: Simple extensions to add Supabase handling to your exception toolkit
- 🛠️ **Highly Customizable**: Override default error messages and behaviors

## Installation

```yaml
dependencies:
  arsync_exception_toolkit: latest_version
  arsync_supabase_errors_handler: latest_version
  supabase_flutter: latest_version  # Required for Supabase
```

## Basic Usage

### 1. Add Supabase handlers to your toolkit

```dart
// Create a toolkit with all Supabase handlers
final toolkit = ArsyncExceptionToolkit(
  handlers: [SupabaseErrorsHandler()],
);

// Or add specific handlers
final toolkit = ArsyncExceptionToolkit(
  handlers: [
    SupabaseErrorsHandler(
      authHandler: SupabaseAuthHandler(),
      databaseHandler: SupabaseDatabaseHandler(),
    ),
  ],
);
```

### 2. Use in try-catch blocks

```dart
try {
  // Supabase operation that might fail
  await supabase.auth.signInWithPassword(
    email: email,
    password: password,
  );
} catch (e) {
  // The toolkit will automatically detect Supabase Auth errors
  final exception = toolkit.handleException(e);
  
  // User-friendly error information is available
  print(exception.title); // "Invalid Credentials"
  print(exception.message); // "The email or password you entered is incorrect..."
  
  // Show the error to the user
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(exception.briefMessage)),
  );
}
```

## Advanced Features

### Customizing Error Messages

You can customize the error messages for specific error codes using `ArsyncException` objects:

```dart
// Create a toolkit with custom Supabase Auth error messages
final toolkit = ArsyncExceptionToolkit(
    handlers: [
      SupabaseErrorsHandler(
        authHandler: SupabaseAuthHandler(
          customExceptions: {
            SupabaseErrorCodes.invalidCredentials: ArsyncException(
              icon: Icons.lock_outline,
              title: 'Wrong Password',
              message:
                  'The password you entered doesn\'t match our records. Please try again or reset your password.',
              briefTitle: 'Login Failed',
              briefMessage: 'Incorrect password',
              exceptionCode: 'supabase_auth_invalid_credentials',
            ),
          },
        ),
      ),
    ],
  );
```

### Accessing Technical Details

For debugging, you can access the technical details of the exception:

```dart
try {
  final response = await supabase
    .from('profiles')
    .insert({'username': 'test', 'email': 'test@example.com'})
    .execute();
} catch (e) {
  final exception = toolkit.handleException(e);
  
  // Log the technical details for debugging
  print(exception.technicalDetails);
  
  // Show a dialog with technical details in development
  if (kDebugMode) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(exception.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(exception.message),
            const SizedBox(height: 16),
            const Text('Technical Details:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(exception.technicalDetails ?? 'Not available'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
```

## Handler Classes

The package includes these specialized handlers:

1. **SupabaseAuthHandler**: Handles Supabase Authentication errors
2. **SupabaseDatabaseHandler**: Handles PostgreSQL and database errors
3. **SupabaseStorageHandler**: Handles Supabase Storage errors
4. **SupabaseFunctionsHandler**: Handles Edge Functions errors
5. **SupabaseRealtimeHandler**: Handles Realtime subscription errors
6. **SupabaseErrorsHandler**: A combined handler that uses all of the above



## Author

**Atif Siddiqui**
- Email: itsatifsiddiqui@gmail.com
- GitHub: [itsatifsiddiqui](https://github.com/itsatifsiddiqui)
- LinkedIn: [Atif Siddiqui](https://www.linkedin.com/in/atif-siddiqui-213a2217b/)


## About Arsync Solutions

[Arsync Solutions](https://arsyncsolutions.com), We build Flutter apps for iOS, Android, and the web.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Contributing

Contributions are welcome! If you find a bug or want a feature, please open an issue.