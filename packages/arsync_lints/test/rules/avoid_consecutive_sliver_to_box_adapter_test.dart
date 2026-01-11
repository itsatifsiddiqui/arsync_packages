import 'package:analyzer_testing/analysis_rule/analysis_rule.dart';
import 'package:arsync_lints/src/rules/avoid_consecutive_sliver_to_box_adapter.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(AvoidConsecutiveSliverToBoxAdapterTest);
  });
}

@reflectiveTest
class AvoidConsecutiveSliverToBoxAdapterTest extends AnalysisRuleTest {
  @override
  void setUp() {
    rule = AvoidConsecutiveSliverToBoxAdapter();
    super.setUp();
  }

  Future<void> test_good_singleSliverToBoxAdapter() async {
    await assertNoDiagnostics(r'''
// Mock Flutter types
class Widget {
  const Widget();
}
class SliverToBoxAdapter extends Widget {
  final Widget? child;
  const SliverToBoxAdapter({this.child});
}
class SliverList extends Widget {
  const SliverList();
}
class CustomScrollView extends Widget {
  final List<Widget>? slivers;
  const CustomScrollView({this.slivers});
}
class Text extends Widget {
  final String data;
  const Text(this.data);
}

Widget myWidget() {
  return CustomScrollView(
    slivers: <Widget>[
      SliverToBoxAdapter(child: Text('Item 1')),
      SliverList(),
    ],
  );
}
''');
  }

  Future<void> test_good_nonConsecutive() async {
    await assertNoDiagnostics(r'''
// Mock Flutter types
class Widget {
  const Widget();
}
class SliverToBoxAdapter extends Widget {
  final Widget? child;
  const SliverToBoxAdapter({this.child});
}
class SliverAppBar extends Widget {
  final Widget? title;
  const SliverAppBar({this.title});
}
class CustomScrollView extends Widget {
  final List<Widget>? slivers;
  const CustomScrollView({this.slivers});
}
class Text extends Widget {
  final String data;
  const Text(this.data);
}

Widget myWidget() {
  return CustomScrollView(
    slivers: <Widget>[
      SliverToBoxAdapter(child: Text('Item 1')),
      SliverAppBar(title: Text('Header')),
      SliverToBoxAdapter(child: Text('Item 2')),
    ],
  );
}
''');
  }

  Future<void> test_bad_consecutiveSliverToBoxAdapter() async {
    await assertDiagnostics(r'''
// Mock Flutter types
class Widget {
  const Widget();
}
class SliverToBoxAdapter extends Widget {
  final Widget? child;
  const SliverToBoxAdapter({this.child});
}
class CustomScrollView extends Widget {
  final List<Widget>? slivers;
  const CustomScrollView({this.slivers});
}
class Text extends Widget {
  final String data;
  const Text(this.data);
}

Widget myWidget() {
  return CustomScrollView(
    slivers: <Widget>[
      SliverToBoxAdapter(child: Text('Item 1')),
      SliverToBoxAdapter(child: Text('Item 2')),
    ],
  );
}
''', [lint(418, 113)]);
  }

  Future<void> test_ignore_forFile() async {
    await assertNoDiagnostics(r'''
// ignore_for_file: avoid_consecutive_sliver_to_box_adapter

// Mock Flutter types
class Widget {
  const Widget();
}
class SliverToBoxAdapter extends Widget {
  final Widget? child;
  const SliverToBoxAdapter({this.child});
}
class CustomScrollView extends Widget {
  final List<Widget>? slivers;
  const CustomScrollView({this.slivers});
}
class Text extends Widget {
  final String data;
  const Text(this.data);
}

Widget myWidget() {
  return CustomScrollView(
    slivers: <Widget>[
      SliverToBoxAdapter(child: Text('Item 1')),
      SliverToBoxAdapter(child: Text('Item 2')),
    ],
  );
}
''');
  }
}
