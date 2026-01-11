import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:arsync_lints/src/rules/remove_listener.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(RemoveListenerTest);
  });
}

@reflectiveTest
class RemoveListenerTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = RemoveListener();
    super.setUp();
  }

  Future<void> test_good_listenerAddedAndRemoved() async {
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
  void addListener(void Function() listener) {}
  void removeListener(void Function() listener) {}
}

class MyWidget extends StatefulWidget {
  const MyWidget({super.key});
}

class _MyWidgetState extends State<MyWidget> {
  final _notifier = ChangeNotifier();

  @override
  void initState() {
    super.initState();
    _notifier.addListener(_onChanged);
  }

  @override
  void dispose() {
    _notifier.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {}

  @override
  Widget build(BuildContext context) => const Widget();
}
''');
  }

  Future<void> test_good_noListenersAdded() async {
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

class MyWidget extends StatefulWidget {
  const MyWidget({super.key});
}

class _MyWidgetState extends State<MyWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) => const Widget();
}
''');
  }

  Future<void> test_good_statusListenerAddedAndRemoved() async {
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

enum AnimationStatus { forward, reverse, completed, dismissed }

class Animation<T> {
  void addStatusListener(void Function(AnimationStatus) listener) {}
  void removeStatusListener(void Function(AnimationStatus) listener) {}
}

class MyWidget extends StatefulWidget {
  const MyWidget({super.key});
}

class _MyWidgetState extends State<MyWidget> {
  final _animation = Animation<double>();

  @override
  void initState() {
    super.initState();
    _animation.addStatusListener(_onStatusChanged);
  }

  @override
  void dispose() {
    _animation.removeStatusListener(_onStatusChanged);
    super.dispose();
  }

  void _onStatusChanged(AnimationStatus status) {}

  @override
  Widget build(BuildContext context) => const Widget();
}
''');
  }

  Future<void> test_good_nonStateClass() async {
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
  void addListener(void Function() listener) {}
  void removeListener(void Function() listener) {}
}

// Not a State class, so no lint
class MyService {
  final _notifier = ChangeNotifier();

  void init() {
    _notifier.addListener(_onChanged);
  }

  void _onChanged() {}
}
''');
  }

  Future<void> test_bad_listenerNotRemoved() async {
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
  void addListener(void Function() listener) {}
  void removeListener(void Function() listener) {}
}

class MyWidget extends StatefulWidget {
  const MyWidget({super.key});
}

class _MyWidgetState extends State<MyWidget> {
  final _notifier = ChangeNotifier();

  @override
  void initState() {
    super.initState();
    _notifier.addListener(_onChanged);
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _onChanged() {}

  @override
  Widget build(BuildContext context) => const Widget();
}
''', [lint(654, 33)]);
  }

  Future<void> test_bad_listenerAddedInDidChangeDependencies() async {
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
  void didChangeDependencies() {}
  void dispose() {}
  Widget build(BuildContext context) => const Widget();
}

class ChangeNotifier {
  void addListener(void Function() listener) {}
  void removeListener(void Function() listener) {}
}

class MyWidget extends StatefulWidget {
  const MyWidget({super.key});
}

class _MyWidgetState extends State<MyWidget> {
  final _notifier = ChangeNotifier();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _notifier.addListener(_onChanged);
  }

  void _onChanged() {}

  @override
  Widget build(BuildContext context) => const Widget();
}
''', [lint(712, 33)]);
  }

  Future<void> test_ignore_forFile() async {
    await assertNoDiagnostics(r'''
// ignore_for_file: remove_listener

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
  void addListener(void Function() listener) {}
  void removeListener(void Function() listener) {}
}

class MyWidget extends StatefulWidget {
  const MyWidget({super.key});
}

class _MyWidgetState extends State<MyWidget> {
  final _notifier = ChangeNotifier();

  @override
  void initState() {
    super.initState();
    _notifier.addListener(_onChanged);
  }

  void _onChanged() {}

  @override
  Widget build(BuildContext context) => const Widget();
}
''');
  }
}
