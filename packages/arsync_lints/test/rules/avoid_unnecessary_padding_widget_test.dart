import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:arsync_lints/src/rules/avoid_unnecessary_padding_widget.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(AvoidUnnecessaryPaddingWidgetTest);
  });
}

@reflectiveTest
class AvoidUnnecessaryPaddingWidgetTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = AvoidUnnecessaryPaddingWidget();
    super.setUp();
  }

  Future<void> test_good_containerWithMargin() async {
    await assertNoDiagnostics(r'''
// Mock types
class EdgeInsets {
  final double value;
  const EdgeInsets.all(this.value);
}
class Widget {
  const Widget();
}
class Container extends Widget {
  final EdgeInsets? margin;
  final Widget? child;
  const Container({this.margin, this.child});
}
class Text extends Widget {
  final String data;
  const Text(this.data);
}

Widget build() {
  return Container(
    margin: EdgeInsets.all(8),
    child: Text('Hello'),
  );
}
''');
  }

  Future<void> test_good_containerWithPadding() async {
    await assertNoDiagnostics(r'''
// Mock types
class EdgeInsets {
  final double value;
  const EdgeInsets.all(this.value);
}
class Widget {
  const Widget();
}
class Container extends Widget {
  final EdgeInsets? padding;
  final Widget? child;
  const Container({this.padding, this.child});
}
class Text extends Widget {
  final String data;
  const Text(this.data);
}

Widget build() {
  return Container(
    padding: EdgeInsets.all(8),
    child: Text('Hello'),
  );
}
''');
  }

  Future<void> test_good_paddingWithNonContainer() async {
    await assertNoDiagnostics(r'''
// Mock types
class EdgeInsets {
  final double value;
  const EdgeInsets.all(this.value);
}
class Widget {
  const Widget();
}
class Padding extends Widget {
  final EdgeInsets padding;
  final Widget? child;
  const Padding({required this.padding, this.child});
}
class Text extends Widget {
  final String data;
  const Text(this.data);
}

Widget build() {
  return Padding(
    padding: EdgeInsets.all(8),
    child: Text('Hello'),
  );
}
''');
  }

  Future<void> test_bad_paddingWrapsContainer() async {
    await assertDiagnostics(
      r'''
// Mock types
class EdgeInsets {
  final double value;
  const EdgeInsets.all(this.value);
}
class Widget {
  const Widget();
}
class Padding extends Widget {
  final EdgeInsets padding;
  final Widget? child;
  const Padding({required this.padding, this.child});
}
class Container extends Widget {
  final Widget? child;
  const Container({this.child});
}
class Text extends Widget {
  final String data;
  const Text(this.data);
}

Widget build() {
  return Padding(
    padding: EdgeInsets.all(8),
    child: Container(
      child: Text('Hello'),
    ),
  );
}
''',
      [lint(460, 101)],
    );
  }

  Future<void> test_bad_containerWrapsPadding() async {
    await assertDiagnostics(
      r'''
// Mock types
class EdgeInsets {
  final double value;
  const EdgeInsets.all(this.value);
}
class Widget {
  const Widget();
}
class Padding extends Widget {
  final EdgeInsets padding;
  final Widget? child;
  const Padding({required this.padding, this.child});
}
class Container extends Widget {
  final Widget? child;
  const Container({this.child});
}
class Text extends Widget {
  final String data;
  const Text(this.data);
}

Widget build() {
  return Container(
    child: Padding(
      padding: EdgeInsets.all(8),
      child: Text('Hello'),
    ),
  );
}
''',
      [lint(460, 103)],
    );
  }

  Future<void> test_good_paddingWrapsContainerWithMargin() async {
    // Should not warn if Container already has margin
    await assertNoDiagnostics(r'''
// Mock types
class EdgeInsets {
  final double value;
  const EdgeInsets.all(this.value);
}
class Widget {
  const Widget();
}
class Padding extends Widget {
  final EdgeInsets padding;
  final Widget? child;
  const Padding({required this.padding, this.child});
}
class Container extends Widget {
  final EdgeInsets? margin;
  final Widget? child;
  const Container({this.margin, this.child});
}
class Text extends Widget {
  final String data;
  const Text(this.data);
}

Widget build() {
  return Padding(
    padding: EdgeInsets.all(8),
    child: Container(
      margin: EdgeInsets.all(4),
      child: Text('Hello'),
    ),
  );
}
''');
  }

  Future<void> test_good_containerWithPaddingWrapsPadding() async {
    // Should not warn if Container already has padding
    await assertNoDiagnostics(r'''
// Mock types
class EdgeInsets {
  final double value;
  const EdgeInsets.all(this.value);
}
class Widget {
  const Widget();
}
class Padding extends Widget {
  final EdgeInsets padding;
  final Widget? child;
  const Padding({required this.padding, this.child});
}
class Container extends Widget {
  final EdgeInsets? padding;
  final Widget? child;
  const Container({this.padding, this.child});
}
class Text extends Widget {
  final String data;
  const Text(this.data);
}

Widget build() {
  return Container(
    padding: EdgeInsets.all(16),
    child: Padding(
      padding: EdgeInsets.all(8),
      child: Text('Hello'),
    ),
  );
}
''');
  }

  Future<void> test_ignore_forFile() async {
    await assertNoDiagnostics(r'''
// ignore_for_file: avoid_unnecessary_padding_widget

// Mock types
class EdgeInsets {
  final double value;
  const EdgeInsets.all(this.value);
}
class Widget {
  const Widget();
}
class Padding extends Widget {
  final EdgeInsets padding;
  final Widget? child;
  const Padding({required this.padding, this.child});
}
class Container extends Widget {
  final Widget? child;
  const Container({this.child});
}
class Text extends Widget {
  final String data;
  const Text(this.data);
}

Widget build() {
  return Padding(
    padding: EdgeInsets.all(8),
    child: Container(
      child: Text('Hello'),
    ),
  );
}
''');
  }
}
