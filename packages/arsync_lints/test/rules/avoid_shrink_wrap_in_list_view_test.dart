import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:arsync_lints/src/rules/avoid_shrink_wrap_in_list_view.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(AvoidShrinkWrapInListViewTest);
  });
}

@reflectiveTest
class AvoidShrinkWrapInListViewTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = AvoidShrinkWrapInListView();
    super.setUp();
  }

  Future<void> test_good_listViewWithoutShrinkWrap() async {
    await assertNoDiagnostics(r'''
// Mock Flutter types
class Widget {
  const Widget();
}
class ListView extends Widget {
  final List<Widget>? children;
  final bool? shrinkWrap;
  const ListView({this.children, this.shrinkWrap});
}
class Text extends Widget {
  final String data;
  const Text(this.data);
}

Widget myWidget() {
  return ListView(
    children: <Widget>[
      Text('Hello'),
      Text('World'),
    ],
  );
}
''');
  }

  Future<void> test_good_shrinkWrapWithoutParent() async {
    // shrinkWrap: true without a parent scrollable/flex is OK
    await assertNoDiagnostics(r'''
// Mock Flutter types
class Widget {
  const Widget();
}
class ListView extends Widget {
  final List<Widget>? children;
  final bool? shrinkWrap;
  const ListView({this.children, this.shrinkWrap});
}
class Scaffold extends Widget {
  final Widget? body;
  const Scaffold({this.body});
}
class Text extends Widget {
  final String data;
  const Text(this.data);
}

Widget myWidget() {
  return Scaffold(
    body: ListView(
      shrinkWrap: true,
      children: <Widget>[
        Text('Hello'),
      ],
    ),
  );
}
''');
  }

  Future<void> test_bad_shrinkWrapInColumn() async {
    await assertDiagnostics(
      r'''
// Mock Flutter types
class Widget {
  const Widget();
}
class Column extends Widget {
  final List<Widget>? children;
  const Column({this.children});
}
class ListView extends Widget {
  final List<Widget>? children;
  final bool? shrinkWrap;
  const ListView({this.children, this.shrinkWrap});
}
class Text extends Widget {
  final String data;
  const Text(this.data);
}

Widget myWidget() {
  return Column(
    children: <Widget>[
      ListView(
        shrinkWrap: true,
        children: <Widget>[
          Text('Hello'),
        ],
      ),
    ],
  );
}
''',
      [lint(442, 107)],
    );
  }

  Future<void> test_ignore_forFile() async {
    await assertNoDiagnostics(r'''
// ignore_for_file: avoid_shrink_wrap_in_list_view

// Mock Flutter types
class Widget {
  const Widget();
}
class Column extends Widget {
  final List<Widget>? children;
  const Column({this.children});
}
class ListView extends Widget {
  final List<Widget>? children;
  final bool? shrinkWrap;
  const ListView({this.children, this.shrinkWrap});
}
class Text extends Widget {
  final String data;
  const Text(this.data);
}

Widget myWidget() {
  return Column(
    children: <Widget>[
      ListView(
        shrinkWrap: true,
        children: <Widget>[
          Text('Hello'),
        ],
      ),
    ],
  );
}
''');
  }
}
