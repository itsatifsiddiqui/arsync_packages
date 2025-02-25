# Arsync Firebase Errors Handler

A specialized package for handling Firebase-specific errors with the [Arsync Exception Toolkit](https://pub.dev/packages/arsync_exception_toolkit).

[![pub package](https://img.shields.io/pub/v/arsync_firebase_errors_handler.svg)](https://pub.dev/packages/arsync_firebase_errors_handler)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

## Features

- ✨ **Specialized Firebase Error Handling**: Provides human-friendly error messages for Firebase service exceptions
- 🔍 **Service-Specific Handlers**: Dedicated handlers for Auth, Firestore, Functions, Storage, and Core Firebase errors
- 🎯 **Detailed Error Information**: Includes detailed technical information for debugging
- 🚀 **Easy Integration**: Simple extensions to add Firebase handling to your exception toolkit
- 🛠️ **Highly Customizable**: Override default error messages and behaviors

## Installation

```yaml
dependencies:
  arsync_exception_toolkit: ^0.1.0
  arsync_firebase_errors_handler: ^0.1.0
  # Other Firebase packages as needed
```

## Basic Usage

### 1. Add Firebase handlers to your toolkit

```dart
// Create a toolkit with all Firebase handlers
final toolkit = ArsyncExceptionToolkit()
  .withAllFirebaseHandlers();

// Or add specific handlers
final toolkit = ArsyncExceptionToolkit()
  .withFirebaseAuthHandler()
  .withFirestoreHandler();
```

### 2. Use in try-catch blocks

```dart
try {
  // Firebase operation that might fail
  await FirebaseAuth.instance.signInWithEmailAndPassword(
    email: email,
    password: password,
  );
} catch (e) {
  // The toolkit will automatically detect Firebase Auth errors
  final exception = toolkit.handleException(e);
  
  // User-friendly error information is available
  print(exception.title); // "Incorrect Password"
  print(exception.message); // "The password you entered is incorrect..."
  
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
// Create a toolkit with custom Firebase Auth error messages
final toolkit = ArsyncExceptionToolkit()
  .withFirebaseAuthHandler(
    customExceptions: {
      FirebaseErrorCodes.wrongPassword: ArsyncException(
        icon: Icons.lock_outline,
        title: 'Wrong Password',
        message: 'The password you entered doesn\'t match our records. Please try again or use the "Forgot Password" option.',
        briefTitle: 'Login Failed',
        briefMessage: 'Incorrect password',
        exceptionCode: 'firebase_auth_wrong_password',
      ),
    },
  );
```

### Using Specific Service Handlers

You can choose which Firebase service handlers to include:

```dart
// Only include handlers for the services you use
final toolkit = ArsyncExceptionToolkit()
  .withFirebaseAuthHandler()
  .withFirestoreHandler();
```

### Accessing Technical Details

For debugging, you can access the technical details of the exception:

```dart
try {
  await FirebaseFirestore.instance.collection('users').doc('nonexistent').get();
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

1. **FirebaseAuthHandler**: Handles Firebase Authentication errors
2. **FirestoreHandler**: Handles Firestore database errors
3. **FirebaseFunctionsHandler**: Handles Cloud Functions errors
4. **FirebaseStorageHandler**: Handles Firebase Storage errors
5. **FirebaseCoreHandler**: Handles general Firebase Core errors
6. **FirebaseErrorsHandler**: A combined handler that uses all of the above


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