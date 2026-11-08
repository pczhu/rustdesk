import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hbb/common/widgets/remote_input.dart';
import 'package:flutter_hbb/models/input_model.dart';
import 'package:flutter_test/flutter_test.dart';

class _RecordingInputModel implements InputModel {
  final events = <KeyEvent>[];

  @override
  KeyEventResult handleKeyEvent(KeyEvent event) {
    events.add(event);
    return KeyEventResult.handled;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets(
      'Key down and key up use the original input handler without a local handler',
      (tester) async {
    final input = _RecordingInputModel();
    await tester.pumpWidget(MaterialApp(
      home: RawKeyFocusScope(inputModel: input, child: const SizedBox()),
    ));
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.keyA);
    expect(input.events, hasLength(2));
    expect(input.events.first, isA<KeyDownEvent>());
    expect(input.events.last, isA<KeyUpEvent>());
  });

  testWidgets(
      'Local confirm stays local while arrow and regular keys use the original handler',
      (tester) async {
    final input = _RecordingInputModel();
    var confirmations = 0;
    await tester.pumpWidget(MaterialApp(
      home: RawKeyFocusScope(
        inputModel: input,
        onKeyEvent: (event) {
          if (event.logicalKey != LogicalKeyboardKey.select) {
            return KeyEventResult.ignored;
          }
          if (event is KeyDownEvent) confirmations++;
          return KeyEventResult.handled;
        },
        child: const SizedBox(),
      ),
    ));
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.select);
    expect(confirmations, 1);
    expect(input.events, isEmpty);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyA);
    expect(input.events.map((e) => e.logicalKey), [
      LogicalKeyboardKey.arrowLeft,
      LogicalKeyboardKey.arrowLeft,
      LogicalKeyboardKey.keyA,
      LogicalKeyboardKey.keyA,
    ]);
  });
}
