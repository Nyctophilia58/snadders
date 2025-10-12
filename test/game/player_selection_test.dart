import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snadders/game/player_selection.dart';

void main() {
  testWidgets('Player selection dialog returns correct value', (WidgetTester tester) async {
    int? selectedValue;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () async {
                selectedValue = await showPlayerSelectionDialog(context);
              },
              child: const Text('Open Dialog'),
            );
          },
        ),
      ),
    );

    // Tap button to open dialog
    await tester.tap(find.text('Open Dialog'));
    await tester.pumpAndSettle();

    // Verify dialog shows options
    expect(find.text('2 Players'), findsOneWidget);
    expect(find.text('4 Players'), findsOneWidget);

    // Check if list subtitles are present
    expect(find.text('One vs Computer'), findsOneWidget);
    expect(find.text('Team vs Team'), findsOneWidget);

    // Check the icons
    expect(find.byIcon(Icons.people), findsOneWidget);
    expect(find.byIcon(Icons.group), findsOneWidget);

    // Tap 2 Players
    await tester.tap(find.text('2 Players'));
    await tester.pumpAndSettle();

    // Verify returned value
    expect(selectedValue, 2);
  });
}
