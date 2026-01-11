import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:arsync_lints/src/rules/unnecessary_container.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(UnnecessaryContainerTest);
  });
}

@reflectiveTest
class UnnecessaryContainerTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = UnnecessaryContainer();
    super.setUp();
  }

  Future<void> test_good_containerWithPadding() async {
    await assertNoDiagnostics(r'''
// Mock types
class Widget {
  const Widget();
}
class EdgeInsets {
  const EdgeInsets.all(double value);
}
class Container extends Widget {
  const Container({this.padding, this.child});
  final EdgeInsets? padding;
  final Widget? child;
}
class Text extends Widget {
  const Text(String text);
}

Widget build() {
  return Container(
    padding: const EdgeInsets.all(8),
    child: const Text('Hello'),
  );
}
''');
  }

  Future<void> test_good_containerWithColor() async {
    await assertNoDiagnostics(r'''
// Mock types
class Widget {
  const Widget();
}
class Color {
  const Color(int value);
  static const red = Color(0xFFFF0000);
}
class Container extends Widget {
  const Container({this.color, this.child});
  final Color? color;
  final Widget? child;
}
class Text extends Widget {
  const Text(String text);
}

Widget build() {
  return Container(
    color: Color.red,
    child: const Text('Hello'),
  );
}
''');
  }

  Future<void> test_good_containerWithMargin() async {
    await assertNoDiagnostics(r'''
// Mock types
class Widget {
  const Widget();
}
class EdgeInsets {
  const EdgeInsets.all(double value);
}
class Container extends Widget {
  const Container({this.margin, this.child});
  final EdgeInsets? margin;
  final Widget? child;
}
class Text extends Widget {
  const Text(String text);
}

Widget build() {
  return Container(
    margin: const EdgeInsets.all(16),
    child: const Text('Hello'),
  );
}
''');
  }

  Future<void> test_good_containerWithDecoration() async {
    await assertNoDiagnostics(r'''
// Mock types
class Widget {
  const Widget();
}
class BoxDecoration {
  const BoxDecoration();
}
class Container extends Widget {
  const Container({this.decoration, this.child});
  final BoxDecoration? decoration;
  final Widget? child;
}
class Text extends Widget {
  const Text(String text);
}

Widget build() {
  return Container(
    decoration: const BoxDecoration(),
    child: const Text('Hello'),
  );
}
''');
  }

  Future<void> test_good_containerWithWidth() async {
    await assertNoDiagnostics(r'''
// Mock types
class Widget {
  const Widget();
}
class Container extends Widget {
  const Container({this.width, this.child});
  final double? width;
  final Widget? child;
}
class Text extends Widget {
  const Text(String text);
}

Widget build() {
  return Container(
    width: 100,
    child: const Text('Hello'),
  );
}
''');
  }

  Future<void> test_good_containerWithHeight() async {
    await assertNoDiagnostics(r'''
// Mock types
class Widget {
  const Widget();
}
class Container extends Widget {
  const Container({this.height, this.child});
  final double? height;
  final Widget? child;
}
class Text extends Widget {
  const Text(String text);
}

Widget build() {
  return Container(
    height: 100,
    child: const Text('Hello'),
  );
}
''');
  }

  Future<void> test_good_containerWithAlignment() async {
    await assertNoDiagnostics(r'''
// Mock types
class Widget {
  const Widget();
}
class Alignment {
  static const center = Alignment();
  const Alignment();
}
class Container extends Widget {
  const Container({this.alignment, this.child});
  final Alignment? alignment;
  final Widget? child;
}
class Text extends Widget {
  const Text(String text);
}

Widget build() {
  return Container(
    alignment: Alignment.center,
    child: const Text('Hello'),
  );
}
''');
  }

  Future<void> test_good_containerWithConstraints() async {
    await assertNoDiagnostics(r'''
// Mock types
class Widget {
  const Widget();
}
class BoxConstraints {
  const BoxConstraints({this.maxWidth});
  final double? maxWidth;
}
class Container extends Widget {
  const Container({this.constraints, this.child});
  final BoxConstraints? constraints;
  final Widget? child;
}
class Text extends Widget {
  const Text(String text);
}

Widget build() {
  return Container(
    constraints: const BoxConstraints(maxWidth: 200),
    child: const Text('Hello'),
  );
}
''');
  }

  Future<void> test_good_containerWithTransform() async {
    await assertNoDiagnostics(r'''
// Mock types
class Widget {
  const Widget();
}
class Matrix4 {
  static Matrix4 rotationZ(double radians) => Matrix4();
}
class Container extends Widget {
  const Container({this.transform, this.child});
  final Matrix4? transform;
  final Widget? child;
}
class Text extends Widget {
  const Text(String text);
}

Widget build() {
  return Container(
    transform: Matrix4.rotationZ(0.1),
    child: const Text('Hello'),
  );
}
''');
  }

  Future<void> test_good_noChild() async {
    await assertNoDiagnostics(r'''
// Mock types
class Widget {
  const Widget();
}
class Container extends Widget {
  const Container();
}

Widget build() {
  return Container();
}
''');
  }

  Future<void> test_bad_containerWithOnlyChild() async {
    await assertDiagnostics(
      r'''
// Mock types
class Widget {
  const Widget();
}
class Container extends Widget {
  const Container({this.child});
  final Widget? child;
}
class Text extends Widget {
  const Text(String text);
}

Widget build() {
  return Container(
    child: const Text('Hello'),
  );
}
''',
      [lint(224, 46)],
    );
  }

  Future<void> test_bad_containerWithOnlyKeyAndChild() async {
    await assertDiagnostics(
      r'''
// Mock types
class Widget {
  const Widget();
}
class Key {
  const Key(String value);
}
class Container extends Widget {
  const Container({this.key, this.child});
  final Key? key;
  final Widget? child;
}
class Text extends Widget {
  const Text(String text);
}

Widget build() {
  return Container(
    key: const Key('myKey'),
    child: const Text('Hello'),
  );
}
''',
      [lint(293, 75)],
    );
  }

  Future<void> test_bad_containerWithClipBehaviorNone() async {
    await assertDiagnostics(
      r'''
// Mock types
class Widget {
  const Widget();
}
enum Clip { none, hardEdge, antiAlias }
class Container extends Widget {
  const Container({this.clipBehavior = Clip.none, this.child});
  final Clip clipBehavior;
  final Widget? child;
}
class Text extends Widget {
  const Text(String text);
}

Widget build() {
  return Container(
    clipBehavior: Clip.none,
    child: const Text('Hello'),
  );
}
''',
      [lint(322, 75)],
    );
  }

  Future<void> test_good_containerWithClipBehaviorHardEdge() async {
    await assertNoDiagnostics(r'''
// Mock types
class Widget {
  const Widget();
}
enum Clip { none, hardEdge, antiAlias }
class Container extends Widget {
  const Container({this.clipBehavior = Clip.none, this.child});
  final Clip clipBehavior;
  final Widget? child;
}
class Text extends Widget {
  const Text(String text);
}

Widget build() {
  return Container(
    clipBehavior: Clip.hardEdge,
    child: const Text('Hello'),
  );
}
''');
  }

  Future<void> test_ignore_forFile() async {
    await assertNoDiagnostics(r'''
// ignore_for_file: unnecessary_container

// Mock types
class Widget {
  const Widget();
}
class Container extends Widget {
  const Container({this.child});
  final Widget? child;
}
class Text extends Widget {
  const Text(String text);
}

Widget build() {
  return Container(
    child: const Text('Hello'),
  );
}
''');
  }

  Future<void> test_ignore_forLine() async {
    await assertNoDiagnostics(r'''
// Mock types
class Widget {
  const Widget();
}
class Container extends Widget {
  const Container({this.child});
  final Widget? child;
}
class Text extends Widget {
  const Text(String text);
}

Widget build() {
  // ignore: unnecessary_container
  return Container(
    child: const Text('Hello'),
  );
}
''');
  }
}
