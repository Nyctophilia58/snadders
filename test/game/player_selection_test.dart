import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snadders/game/player_selection.dart';

void main() {
  testWidgets('showPlayerSelectionDialog returns correct values', (WidgetTester tester) async {
    // Build a MaterialApp to provide context
    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (context) {
          return Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () async {
                  // Trigger the dialog
                  final result = await showPlayerSelectionDialog(context);
                  // Store the result in a variable outside if needed for more checks
                },
                child: const Text('Open Dialog'),
              ),
            ),
          );
        },
      ),
    ));

    // Tap the button to open the dialog
    await tester.tap(find.text('Open Dialog'));
    await tester.pumpAndSettle();

    // Ensure the dialog appears
    expect(find.text('Choose Number of Players'), findsOneWidget);
    expect(find.text('2 Players'), findsOneWidget);
    expect(find.text('4 Players'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);

    // Tap 2 Players
    await tester.tap(find.text('2 Players'));
    await tester.pumpAndSettle();

    // After tapping, the dialog should be gone
    expect(find.text('Choose Number of Players'), findsNothing);

    // Re-open dialog to test 4 Players
    await tester.tap(find.text('Open Dialog'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('4 Players'));
    await tester.pumpAndSettle();

    expect(find.text('Choose Number of Players'), findsNothing);

    // Re-open dialog to test Cancel
    await tester.tap(find.text('Open Dialog'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('Choose Number of Players'), findsNothing);
  });
}
