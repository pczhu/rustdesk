import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hbb/mobile/widgets/dpad_focus.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Keyboard navigation shows the border and touch hides it',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: DpadFocus(
          onPressed: () {},
          child: const SizedBox(width: 100, height: 100),
        ),
      ),
    ));
    Color borderColor() {
      final container = tester.widget<Container>(find.descendant(
        of: find.byType(DpadFocus),
        matching: find.byType(Container),
      ));
      return ((container.foregroundDecoration! as BoxDecoration).border!
              as Border)
          .top
          .color;
    }

    expect(borderColor(), Colors.transparent);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    expect(borderColor(), isNot(Colors.transparent));
    await tester.tap(find.byType(DpadFocus));
    await tester.pump();
    expect(borderColor(), Colors.transparent);
  });

  testWidgets(
      'Arrow keys move focus and confirm activates only the focused widget',
      (tester) async {
    final activations = <int>[];
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Row(
          children: List.generate(
              2,
              (index) => DpadFocus(
                    onPressed: () => activations.add(index),
                    child: SizedBox(
                        width: 100, height: 100, child: Text('$index')),
                  )),
        ),
      ),
    ));

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.select);
    expect(activations, [0]);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.sendKeyEvent(LogicalKeyboardKey.select);
    expect(activations, [0, 1]);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    expect(activations, [0, 1, 0]);
  });

  testWidgets('The nested more button does not trigger a device connection',
      (tester) async {
    var connections = 0;
    var menus = 0;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: DpadFocus(
          onPressed: () => connections++,
          child: Row(children: [
            const SizedBox(width: 100, height: 100),
            DpadFocus(
              onPressed: () => menus++,
              child: ExcludeFocus(
                child: InkWell(
                  onTap: () {},
                  child: const SizedBox(width: 40, height: 40),
                ),
              ),
            ),
          ]),
        ),
      ),
    ));

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.select);
    expect(menus, 1);
    expect(connections, 0);
  });

  testWidgets('Focusing an offscreen widget scrolls it into view',
      (tester) async {
    final scrollController = ScrollController();
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SizedBox(
          height: 150,
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
                children: List.generate(
                    6,
                    (index) => DpadFocus(
                          onPressed: () {},
                          child: SizedBox(
                              height: 100, width: 100, child: Text('$index')),
                        ))),
          ),
        ),
      ),
    ));

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    for (var i = 0; i < 5; i++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
    }
    expect(scrollController.offset, greaterThan(0));
    expect(tester.getRect(find.text('5')).bottom, lessThanOrEqualTo(150));
    for (var i = 0; i < 5; i++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pumpAndSettle();
    }
    expect(tester.getRect(find.text('0')).top, greaterThanOrEqualTo(0));
    await tester.pumpWidget(const SizedBox());
    scrollController.dispose();
  });

  testWidgets(
      'Touch uses the original gesture handler without duplicate activation',
      (tester) async {
    var taps = 0;
    var confirmations = 0;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: DpadFocus(
          onPressed: () => confirmations++,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => taps++,
            child: const SizedBox(width: 100, height: 100),
          ),
        ),
      ),
    ));
    await tester.tap(find.byType(GestureDetector));
    expect(taps, 1);
    expect(confirmations, 0);
  });
}
