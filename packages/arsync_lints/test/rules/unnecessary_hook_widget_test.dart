import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:arsync_lints/src/rules/unnecessary_hook_widget.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(UnnecessaryHookWidgetTest);
  });
}

@reflectiveTest
class UnnecessaryHookWidgetTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = UnnecessaryHookWidget();
    super.setUp();
  }

  Future<void> test_good_hookWidgetWithHook() async {
    await assertNoDiagnostics(r'''
// Mock types
class Widget {
  const Widget();
}
class BuildContext {}
class HookWidget extends Widget {
  const HookWidget({this.key});
  final Object? key;
  Widget build(BuildContext context) => const Widget();
}
class TextEditingController {}

TextEditingController useTextEditingController() => TextEditingController();

class MyWidget extends HookWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = useTextEditingController();
    return const Widget();
  }
}
''');
  }

  Future<void> test_good_hookWidgetWithUseState() async {
    await assertNoDiagnostics(r'''
// Mock types
class Widget {
  const Widget();
}
class BuildContext {}
class HookWidget extends Widget {
  const HookWidget({this.key});
  final Object? key;
  Widget build(BuildContext context) => const Widget();
}

T useState<T>(T initialValue) => initialValue;

class MyWidget extends HookWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final count = useState(0);
    return const Widget();
  }
}
''');
  }

  Future<void> test_good_statelessWidget() async {
    await assertNoDiagnostics(r'''
// Mock types
class Widget {
  const Widget();
}
class BuildContext {}
class StatelessWidget extends Widget {
  const StatelessWidget({this.key});
  final Object? key;
  Widget build(BuildContext context) => const Widget();
}

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Widget();
  }
}
''');
  }

  Future<void> test_good_hookWidgetWithPrivateHook() async {
    await assertNoDiagnostics(r'''
// Mock types
class Widget {
  const Widget();
}
class BuildContext {}
class HookWidget extends Widget {
  const HookWidget({this.key});
  final Object? key;
  Widget build(BuildContext context) => const Widget();
}

String _useCustomHook() => 'hook';

class MyWidget extends HookWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final value = _useCustomHook();
    return const Widget();
  }
}
''');
  }

  Future<void> test_bad_hookWidgetWithoutHooks() async {
    await assertDiagnostics(
      r'''
// Mock types
class Widget {
  const Widget();
}
class BuildContext {}
class HookWidget extends Widget {
  const HookWidget({this.key});
  final Object? key;
  Widget build(BuildContext context) => const Widget();
}

class MyWidget extends HookWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Widget();
  }
}
''',
      [lint(240, 10)],
    );
  }

  Future<void> test_bad_hookWidgetWithUnrelatedMethods() async {
    await assertDiagnostics(
      r'''
// Mock types
class Widget {
  const Widget();
}
class BuildContext {}
class HookWidget extends Widget {
  const HookWidget({this.key});
  final Object? key;
  Widget build(BuildContext context) => const Widget();
}

class MyWidget extends HookWidget {
  const MyWidget({super.key});

  void someMethod() {
    print('not a hook');
  }

  @override
  Widget build(BuildContext context) {
    someMethod();
    return const Widget();
  }
}
''',
      [lint(240, 10)],
    );
  }

  Future<void> test_ignore_forFile() async {
    await assertNoDiagnostics(r'''
// ignore_for_file: unnecessary_hook_widget

// Mock types
class Widget {
  const Widget();
}
class BuildContext {}
class HookWidget extends Widget {
  const HookWidget({this.key});
  final Object? key;
  Widget build(BuildContext context) => const Widget();
}

class MyWidget extends HookWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Widget();
  }
}
''');
  }

  Future<void> test_ignore_forLine() async {
    await assertNoDiagnostics(r'''
// Mock types
class Widget {
  const Widget();
}
class BuildContext {}
class HookWidget extends Widget {
  const HookWidget({this.key});
  final Object? key;
  Widget build(BuildContext context) => const Widget();
}

// ignore: unnecessary_hook_widget
class MyWidget extends HookWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Widget();
  }
}
''');
  }
}
