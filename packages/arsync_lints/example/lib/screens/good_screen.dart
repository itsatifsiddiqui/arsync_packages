// Example: GOOD - This file demonstrates correct screen usage

// OK: Importing from providers layer (not repositories)
// ignore: unused_import
import '../providers/auth_provider.dart';
// ignore: unused_import
import '../providers/user_provider.dart';

// Mock Flutter types for demonstration
class Widget {}

class StatelessWidget extends Widget {}

class BuildContext {}

// OK: Using Dart records instead of parameter classes
typedef UpdateProfileParams = ({
  String userId,
  String name,
  String email,
  String? phone,
});

class GoodScreen extends StatelessWidget {
  // OK: Private helper method
  bool _mockCondition() => false;

  // OK: Method using record type for parameters
  void _updateUserProfile(UpdateProfileParams params) {
    // Clean API with single parameter object (record)
    // ignore: unused_local_variable
    final userId = params.userId;
  }

  Widget build(BuildContext context) {
    // OK: Accessing state through providers (not direct repo access)
    // final authState = ref.watch(authNotifierProvider);

    // OK: No nested ternary - using if/else
    final isLoading = _mockCondition();
    final hasError = _mockCondition();

    // OK: Using record for parameter passing
    _updateUserProfile((
      userId: '123',
      name: 'John',
      email: 'john@example.com',
      phone: null,
    ));

    if (isLoading) {
      return Widget(); // Loading widget
    }
    if (hasError) {
      return Widget(); // Error widget
    }
    return Widget(); // Content widget
  }
}
