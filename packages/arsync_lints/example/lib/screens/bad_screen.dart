// Example: BAD - This file demonstrates violations in screens

// VIOLATION: presentation_layer_isolation - Direct repository import
// ignore: unused_import
import 'package:dio/dio.dart';

import '../repositories/user_repository.dart';

// Mock Flutter types for demonstration
class Widget {}

class StatelessWidget extends Widget {}

class HookConsumerWidget extends Widget {}

class BuildContext {}

class TextEditingController {}

class ScrollController {}

class FormState {}

class GlobalKey<T> {}

class GlobalObjectKey<T> {
  GlobalObjectKey(Object value);
}

// Helper to avoid dead_code warnings in examples
bool _mockCondition() => false;

class BadHomeScreen extends StatelessWidget {
  // VIOLATION: hook_safety_enforcement - Controllers in build without hooks
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final textController = TextEditingController();
    // ignore: unused_local_variable
    final scrollController = ScrollController();

    // VIOLATION: print_ban
    print('Building BadHomeScreen');

    // VIOLATION: presentation_layer_isolation - Direct repo instantiation
    // ignore: unused_local_variable
    final userRepo = UserRepository(Dio());

    // VIOLATION: complexity_limits - Nested ternary
    final isLoading = _mockCondition();
    final hasError = _mockCondition();
    // ignore: unused_local_variable
    final message = isLoading
        ? 'Loading...'
        : hasError
        ? 'Error occurred'
        : 'Success';

    return Widget();
  }
}

// VIOLATION: complexity_limits - Too many parameters
void updateUserProfile(
  String userId,
  String name,
  String email,
  String phone,
  String address,
  String city,
) {
  // This has more than 4 parameters
}

// VIOLATION: file_class_match - Class name doesn't match file name
class HomeScreenWidget extends StatelessWidget {}

// VIOLATION: global_variable_restriction - Non-private top-level variable
String screenTitle = 'Bad Screen';

// VIOLATION: hook_safety_enforcement - GlobalKey<FormState> in HookConsumerWidget
class BadFormScreen extends HookConsumerWidget {
  Widget build(BuildContext context) {
    // BAD: GlobalKey<FormState>() resets on keyboard open/orientation change
    // ignore: unused_local_variable
    final formKey = GlobalKey<FormState>(); // ERROR!

    // GOOD: Use GlobalObjectKey<FormState>(context) instead
    // final formKey = GlobalObjectKey<FormState>(context);

    return Widget();
  }
}

// VIOLATION: complexity_limits - Build method exceeds 120 lines
class LongBuildMethodScreen extends StatelessWidget {
  Widget build(BuildContext context) {
    // This build method is way too long (>120 lines)
    // It should be refactored into smaller widgets/methods
    // ignore: unused_local_variable
    final line1 = 'Line 1';
    // ignore: unused_local_variable
    final line2 = 'Line 2';
    // ignore: unused_local_variable
    final line3 = 'Line 3';
    // ignore: unused_local_variable
    final line4 = 'Line 4';
    // ignore: unused_local_variable
    final line5 = 'Line 5';
    // ignore: unused_local_variable
    final line6 = 'Line 6';
    // ignore: unused_local_variable
    final line7 = 'Line 7';
    // ignore: unused_local_variable
    final line8 = 'Line 8';
    // ignore: unused_local_variable
    final line9 = 'Line 9';
    // ignore: unused_local_variable
    final line10 = 'Line 10';
    // ignore: unused_local_variable
    final line11 = 'Line 11';
    // ignore: unused_local_variable
    final line12 = 'Line 12';
    // ignore: unused_local_variable
    final line13 = 'Line 13';
    // ignore: unused_local_variable
    final line14 = 'Line 14';
    // ignore: unused_local_variable
    final line15 = 'Line 15';
    // ignore: unused_local_variable
    final line16 = 'Line 16';
    // ignore: unused_local_variable
    final line17 = 'Line 17';
    // ignore: unused_local_variable
    final line18 = 'Line 18';
    // ignore: unused_local_variable
    final line19 = 'Line 19';
    // ignore: unused_local_variable
    final line20 = 'Line 20';
    // ignore: unused_local_variable
    final line21 = 'Line 21';
    // ignore: unused_local_variable
    final line22 = 'Line 22';
    // ignore: unused_local_variable
    final line23 = 'Line 23';
    // ignore: unused_local_variable
    final line24 = 'Line 24';
    // ignore: unused_local_variable
    final line25 = 'Line 25';
    // ignore: unused_local_variable
    final line26 = 'Line 26';
    // ignore: unused_local_variable
    final line27 = 'Line 27';
    // ignore: unused_local_variable
    final line28 = 'Line 28';
    // ignore: unused_local_variable
    final line29 = 'Line 29';
    // ignore: unused_local_variable
    final line30 = 'Line 30';
    // ignore: unused_local_variable
    final line31 = 'Line 31';
    // ignore: unused_local_variable
    final line32 = 'Line 32';
    // ignore: unused_local_variable
    final line33 = 'Line 33';
    // ignore: unused_local_variable
    final line34 = 'Line 34';
    // ignore: unused_local_variable
    final line35 = 'Line 35';
    // ignore: unused_local_variable
    final line36 = 'Line 36';
    // ignore: unused_local_variable
    final line37 = 'Line 37';
    // ignore: unused_local_variable
    final line38 = 'Line 38';
    // ignore: unused_local_variable
    final line39 = 'Line 39';
    // ignore: unused_local_variable
    final line40 = 'Line 40';
    // ignore: unused_local_variable
    final line41 = 'Line 41';
    // ignore: unused_local_variable
    final line42 = 'Line 42';
    // ignore: unused_local_variable
    final line43 = 'Line 43';
    // ignore: unused_local_variable
    final line44 = 'Line 44';
    // ignore: unused_local_variable
    final line45 = 'Line 45';
    // ignore: unused_local_variable
    final line46 = 'Line 46';
    // ignore: unused_local_variable
    final line47 = 'Line 47';
    // ignore: unused_local_variable
    final line48 = 'Line 48';
    // ignore: unused_local_variable
    final line49 = 'Line 49';
    // ignore: unused_local_variable
    final line50 = 'Line 50';
    // ignore: unused_local_variable
    final line51 = 'Line 51';
    // ignore: unused_local_variable
    final line52 = 'Line 52';
    // ignore: unused_local_variable
    final line53 = 'Line 53';
    // ignore: unused_local_variable
    final line54 = 'Line 54';
    // ignore: unused_local_variable
    final line55 = 'Line 55';
    // ignore: unused_local_variable
    final line56 = 'Line 56';
    // ignore: unused_local_variable
    final line57 = 'Line 57';
    // ignore: unused_local_variable
    final line58 = 'Line 58';
    // ignore: unused_local_variable
    final line59 = 'Line 59';
    // ignore: unused_local_variable
    final line60 = 'Line 60';
    // Continuing to exceed 120 lines...
    // ignore: unused_local_variable
    final line61 = 'Line 61';
    // ignore: unused_local_variable
    final line62 = 'Line 62';
    // ignore: unused_local_variable
    final line63 = 'Line 63';
    // ignore: unused_local_variable
    final line64 = 'Line 64';
    // ignore: unused_local_variable
    final line65 = 'Line 65';

    return Widget();
  }

  // VIOLATION: complexity_limits - Method exceeds 60 lines
  Widget buildWidget(BuildContext context) {
    // This method is way too long (>60 lines)
    // It should be refactored into smaller methods
    // ignore: unused_local_variable
    final line1 = 'Line 1';
    // ignore: unused_local_variable
    final line2 = 'Line 2';
    // ignore: unused_local_variable
    final line3 = 'Line 3';
    // ignore: unused_local_variable
    final line4 = 'Line 4';
    // ignore: unused_local_variable
    final line5 = 'Line 5';
    // ignore: unused_local_variable
    final line6 = 'Line 6';
    // ignore: unused_local_variable
    final line7 = 'Line 7';
    // ignore: unused_local_variable
    final line8 = 'Line 8';
    // ignore: unused_local_variable
    final line9 = 'Line 9';
    // ignore: unused_local_variable
    final line10 = 'Line 10';
    // ignore: unused_local_variable
    final line11 = 'Line 11';
    // ignore: unused_local_variable
    final line12 = 'Line 12';
    // ignore: unused_local_variable
    final line13 = 'Line 13';
    // ignore: unused_local_variable
    final line14 = 'Line 14';
    // ignore: unused_local_variable
    final line15 = 'Line 15';
    // ignore: unused_local_variable
    final line16 = 'Line 16';
    // ignore: unused_local_variable
    final line17 = 'Line 17';
    // ignore: unused_local_variable
    final line18 = 'Line 18';
    // ignore: unused_local_variable
    final line19 = 'Line 19';
    // ignore: unused_local_variable
    final line20 = 'Line 20';
    // ignore: unused_local_variable
    final line21 = 'Line 21';
    // ignore: unused_local_variable
    final line22 = 'Line 22';
    // ignore: unused_local_variable
    final line23 = 'Line 23';
    // ignore: unused_local_variable
    final line24 = 'Line 24';
    // ignore: unused_local_variable
    final line25 = 'Line 25';
    // ignore: unused_local_variable
    final line26 = 'Line 26';
    // ignore: unused_local_variable
    final line27 = 'Line 27';
    // ignore: unused_local_variable
    final line28 = 'Line 28';
    // ignore: unused_local_variable
    final line29 = 'Line 29';
    // ignore: unused_local_variable
    final line30 = 'Line 30';
    // ignore: unused_local_variable
    final line31 = 'Line 31';
    // ignore: unused_local_variable
    final line32 = 'Line 32';
    // ignore: unused_local_variable
    final line33 = 'Line 33';
    // ignore: unused_local_variable
    final line34 = 'Line 34';
    // ignore: unused_local_variable
    final line35 = 'Line 35';
    // ignore: unused_local_variable
    final line36 = 'Line 36';
    // ignore: unused_local_variable
    final line37 = 'Line 37';
    // ignore: unused_local_variable
    final line38 = 'Line 38';
    // ignore: unused_local_variable
    final line39 = 'Line 39';
    // ignore: unused_local_variable
    final line40 = 'Line 40';
    // ignore: unused_local_variable
    final line41 = 'Line 41';
    // ignore: unused_local_variable
    final line42 = 'Line 42';
    // ignore: unused_local_variable
    final line43 = 'Line 43';
    // ignore: unused_local_variable
    final line44 = 'Line 44';
    // ignore: unused_local_variable
    final line45 = 'Line 45';
    // ignore: unused_local_variable
    final line46 = 'Line 46';
    // ignore: unused_local_variable
    final line47 = 'Line 47';
    // ignore: unused_local_variable
    final line48 = 'Line 48';
    // ignore: unused_local_variable
    final line49 = 'Line 49';
    // ignore: unused_local_variable
    final line50 = 'Line 50';
    // ignore: unused_local_variable
    final line51 = 'Line 51';
    // ignore: unused_local_variable
    final line52 = 'Line 52';
    // ignore: unused_local_variable
    final line53 = 'Line 53';
    // ignore: unused_local_variable
    final line54 = 'Line 54';
    // ignore: unused_local_variable
    final line55 = 'Line 55';
    // ignore: unused_local_variable
    final line56 = 'Line 56';
    // ignore: unused_local_variable
    final line57 = 'Line 57';
    // ignore: unused_local_variable
    final line58 = 'Line 58';
    // ignore: unused_local_variable
    final line59 = 'Line 59';
    // ignore: unused_local_variable
    final line60 = 'Line 60';
    // Continuing to exceed 120 lines...
    // ignore: unused_local_variable
    final line61 = 'Line 61';
    // ignore: unused_local_variable
    final line62 = 'Line 62';
    // ignore: unused_local_variable
    final line63 = 'Line 63';
    // ignore: unused_local_variable
    final line64 = 'Line 64';
    // ignore: unused_local_variable
    final line65 = 'Line 65';

    return Widget();
  }
}
