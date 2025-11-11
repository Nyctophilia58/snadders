import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snadders/widgets/exit_button.dart';

void main() {
  testWidgets('ExitButton renders correctly and triggers onPressed when tapped', (WidgetTester tester) async {
    bool wasPressed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ExitButton(
            onPressed: () {
              wasPressed = true;
            },
          ),
        ),
      ),
    );

    expect(find.byType(ExitButton), findsOneWidget);

    expect(find.byType(Image), findsOneWidget);

    await tester.tap(find.byType(ExitButton));
    await tester.pumpAndSettle();

    expect(wasPressed, isTrue);
  });
}
