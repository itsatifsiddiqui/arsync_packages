# Arsync Exception Toolkit

A flexible, standardized exception handling system for Flutter applications by Arsync.

[![pub package](https://img.shields.io/pub/v/arsync_exception_toolkit.svg)](https://pub.dev/packages/arsync_exception_toolkit)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

## Features

- ✨ **Standardized Exception Format**: Convert any exception into a user-friendly format
- 🔍 **Automatic Exception Detection**: Intelligently identify exception types
- 🎯 **Specialized Handlers**: Add custom handlers for specific backend services
- 🛠️ **Highly Customizable**: Modify and extend the toolkit to suit your needs

## Installation

```yaml
dependencies:
  arsync_exception_toolkit: ^0.1.0
```

## Basic Usage

### 1. Create the toolkit

```dart
// Create an instance of the toolkit
final exceptionToolkit = ArsyncExceptionToolkit();
```

### 2. Use in try-catch blocks

```dart
try {
  // Code that might throw an exception
  await api.fetchData();
} catch (e) {
  // Handle the exception
  final exception = exceptionToolkit.handleException(e);
  
  // Use the structured exception
  print(exception.title); // "Network Error"
  print(exception.message); // "Unable to connect to the network..."
}
```

### 3. Display exceptions to users

```dart
try {
  await api.authenticate();
} catch (e) {
  final exception = exceptionToolkit.handleException(e);
  
  // Show a dialog
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Row(
        children: [
          Icon(exception.icon, color: Colors.red),
          SizedBox(width: 8),
          Text(exception.title),
        ],
      ),
      content: Text(exception.message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('OK'),
        ),
      ],
    ),
  );
}
```

## Advanced Features

### Custom Exception Handlers

Create specialized handlers for different types of exceptions:

```dart
class FirebaseAuthHandler implements ArsyncExceptionHandler {
  @override
  bool canHandle(Object exception) {
    // Check if this is a Firebase Auth exception
    return exception.toString().contains('FirebaseAuth');
  }

  @override
  ArsyncException handle(Object exception) {
    // Convert to appropriate ArsyncException
    return ArsyncException.authentication(
      title: 'Firebase Auth Error',
      message: 'Authentication failed: ${exception.toString()}',
      originalException: exception,
    );
  }
  
  @override
  int get priority => 10; // Higher priority than general handler
}

// Register your custom handler
final toolkit = ArsyncExceptionToolkit(
  handlers: [FirebaseAuthHandler()],
);
```

### Exception Modifiers

Customize how specific exceptions are presented:

```dart
// Register a modifier for authentication errors
toolkit.registerExceptionModifier(
  'auth_error',
  (exception, originalException) {
    return exception.copyWith(
      title: 'Session Expired',
      message: 'Your session has expired. Please sign in again.',
    );
  },
);
```

### Ignoring Certain Exceptions

Define which exceptions should be ignored: This is useful for ignoring exceptions that are not relevant to the user and should not be displayed.

```dart
final toolkit = ArsyncExceptionToolkit(
  ignorableExceptions: [
    'operation_cancelled',
    'user_dismissed',
  ],
);

// Add more later
toolkit.addIgnorableException('user_aborted');
```

## Extension Packages (Coming Soon)

For specialized backend services, you can use extension packages:

- **arsync_firebase_errors_handler**: Handle Firebase-specific errors
- **arsync_supabase_errors_handler**: Handle Supabase-specific errors
- **arsync_dio_errors_handler**: Handle Dio HTTP errors

Example with Firebase:

```dart
import 'package:arsync_exception_toolkit/arsync_exception_toolkit.dart';
import 'package:arsync_firebase_errors_handler/arsync_firebase_errors_handler.dart';

final toolkit = ArsyncExceptionToolkit(
  handlers: [FirebaseAuthExceptionHandler(), FirebaseFirestoreExceptionHandler()],
);
```



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