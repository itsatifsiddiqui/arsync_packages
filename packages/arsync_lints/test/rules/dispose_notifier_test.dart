import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:arsync_lints/src/rules/dispose_notifier.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(DisposeNotifierTest);
  });
}

@reflectiveTest
class DisposeNotifierTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = DisposeNotifier();
    super.setUp();
  }

  Future<void> test_good_notifierDisposed() async {
    await assertNoDiagnostics(r'''
// Mock types
class Widget {
  const Widget();
}
class BuildContext {}
class StatefulWidget extends Widget {
  const StatefulWidget({this.key});
  final Object? key;
}
class State<T extends StatefulWidget> {
  void initState() {}
  void dispose() {}
  Widget build(BuildContext context) => const Widget();
}

class ChangeNotifier {
  void dispose() {}
}

class TextEditingController extends ChangeNotifier {}

class TextField extends Widget {
  const TextField({this.controller});
  final TextEditingController? controller;
}

class MyWidget extends StatefulWidget {
  const MyWidget({super.key});
}

class _MyWidgetState extends State<MyWidget> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => TextField(controller: _controller);
}
''');
  }

  Future<void> test_good_notifierUnused() async {
    await assertNoDiagnostics(r'''
// Mock types
class Widget {
  const Widget();
}
class BuildContext {}
class StatefulWidget extends Widget {
  const StatefulWidget({this.key});
  final Object? key;
}
class State<T extends StatefulWidget> {
  void initState() {}
  void dispose() {}
  Widget build(BuildContext context) => const Widget();
}

class ChangeNotifier {
  void dispose() {}
}

class TextEditingController extends ChangeNotifier {}

class MyWidget extends StatefulWidget {
  const MyWidget({super.key});
}

// Controller is created but never used, so no warning
class _MyWidgetState extends State<MyWidget> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) => const Widget();
}
''');
  }

  Future<void> test_good_nonStateClass() async {
    await assertNoDiagnostics(r'''
// Mock types
class ChangeNotifier {
  void dispose() {}
}

class TextEditingController extends ChangeNotifier {}

// Not a State class, so no lint
class MyService {
  final _controller = TextEditingController();

  void doSomething() {
    print(_controller);
  }
}
''');
  }

  Future<void> test_bad_notifierNotDisposed() async {
    await assertDiagnostics(r'''
// Mock types
class Widget {
  const Widget();
}
class BuildContext {}
class StatefulWidget extends Widget {
  const StatefulWidget({this.key});
  final Object? key;
}
class State<T extends StatefulWidget> {
  void initState() {}
  void dispose() {}
  Widget build(BuildContext context) => const Widget();
}

class ChangeNotifier {
  void dispose() {}
}

class TextEditingController extends ChangeNotifier {}

class TextField extends Widget {
  const TextField({this.controller});
  final TextEditingController? controller;
}

class MyWidget extends StatefulWidget {
  const MyWidget({super.key});
}

class _MyWidgetState extends State<MyWidget> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => TextField(controller: _controller);
}
''', [lint(656, 37)]);
  }

  Future<void> test_bad_notifierUsedButNoDisposeMethod() async {
    await assertDiagnostics(r'''
// Mock types
class Widget {
  const Widget();
}
class BuildContext {}
class StatefulWidget extends Widget {
  const StatefulWidget({this.key});
  final Object? key;
}
class State<T extends StatefulWidget> {
  void initState() {}
  void dispose() {}
  Widget build(BuildContext context) => const Widget();
}

class ChangeNotifier {
  void dispose() {}
}

class TextEditingController extends ChangeNotifier {}

class TextField extends Widget {
  const TextField({this.controller});
  final TextEditingController? controller;
}

class MyWidget extends StatefulWidget {
  const MyWidget({super.key});
}

class _MyWidgetState extends State<MyWidget> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) => TextField(controller: _controller);
}
''', [lint(656, 37)]);
  }

  Future<void> test_ignore_forFile() async {
    await assertNoDiagnostics(r'''
// ignore_for_file: dispose_notifier

// Mock types
class Widget {
  const Widget();
}
class BuildContext {}
class StatefulWidget extends Widget {
  const StatefulWidget({this.key});
  final Object? key;
}
class State<T extends StatefulWidget> {
  void initState() {}
  void dispose() {}
  Widget build(BuildContext context) => const Widget();
}

class ChangeNotifier {
  void dispose() {}
}

class TextEditingController extends ChangeNotifier {}

class TextField extends Widget {
  const TextField({this.controller});
  final TextEditingController? controller;
}

class MyWidget extends StatefulWidget {
  const MyWidget({super.key});
}

class _MyWidgetState extends State<MyWidget> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) => TextField(controller: _controller);
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
class StatefulWidget extends Widget {
  const StatefulWidget({this.key});
  final Object? key;
}
class State<T extends StatefulWidget> {
  void initState() {}
  void dispose() {}
  Widget build(BuildContext context) => const Widget();
}

class ChangeNotifier {
  void dispose() {}
}

class TextEditingController extends ChangeNotifier {}

class TextField extends Widget {
  const TextField({this.controller});
  final TextEditingController? controller;
}

class MyWidget extends StatefulWidget {
  const MyWidget({super.key});
}

class _MyWidgetState extends State<MyWidget> {
  // ignore: dispose_notifier
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) => TextField(controller: _controller);
}
''');
  }
}
