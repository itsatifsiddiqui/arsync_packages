import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:arsync_lints/src/rules/avoid_single_child.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(AvoidSingleChildTest);
  });
}

@reflectiveTest
class AvoidSingleChildTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = AvoidSingleChild();
    super.setUp();
  }

  Future<void> test_good_multipleChildren() async {
    await assertNoDiagnostics(r'''
// Mock Flutter types
class Widget {
  const Widget();
}
class Column extends Widget {
  final List<Widget>? children;
  const Column({this.children});
}
class Text extends Widget {
  final String data;
  const Text(this.data);
}

Widget myWidget() {
  return Column(
    children: <Widget>[
      Text('First'),
      Text('Second'),
    ],
  );
}
''');
  }

  Future<void> test_good_singleChildWidget() async {
    await assertNoDiagnostics(r'''
// Mock Flutter types
class Widget {
  const Widget();
}
class Center extends Widget {
  final Widget? child;
  const Center({this.child});
}
class Text extends Widget {
  final String data;
  const Text(this.data);
}

Widget myWidget() {
  return Center(
    child: Text('Hello'),
  );
}
''');
  }

  Future<void> test_bad_columnSingleChild() async {
    await assertDiagnostics(r'''
// Mock Flutter types
class Widget {
  const Widget();
}
class Column extends Widget {
  final List<Widget>? children;
  const Column({this.children});
}
class Text extends Widget {
  final String data;
  const Text(this.data);
}

Widget myWidget() {
  return Column(
    children: <Widget>[
      Text('Only child'),
    ],
  );
}
''', [lint(260, 68)]);
  }

  Future<void> test_bad_rowSingleChild() async {
    await assertDiagnostics(r'''
// Mock Flutter types
class Widget {
  const Widget();
}
class Row extends Widget {
  final List<Widget>? children;
  const Row({this.children});
}
class Text extends Widget {
  final String data;
  const Text(this.data);
}

Widget myWidget() {
  return Row(
    children: <Widget>[
      Text('Only child'),
    ],
  );
}
''', [lint(254, 65)]);
  }

  Future<void> test_ignore_forFile() async {
    await assertNoDiagnostics(r'''
// ignore_for_file: avoid_single_child

// Mock Flutter types
class Widget {
  const Widget();
}
class Column extends Widget {
  final List<Widget>? children;
  const Column({this.children});
}
class Text extends Widget {
  final String data;
  const Text(this.data);
}

Widget myWidget() {
  return Column(
    children: <Widget>[
      Text('Only child'),
    ],
  );
}
''');
  }
}
