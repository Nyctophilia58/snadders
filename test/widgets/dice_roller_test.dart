import 'package:flutter_test/flutter_test.dart';
import 'package:snadders/widgets/dice_roller.dart';

void main() {
  testWidgets('DiceRoller does not auto-roll on init when autoRoll is false',
      (WidgetTester tester) async {
    int rolledValue = 0;

    await tester.pumpWidget(DiceRoller(
      autoRoll: false,
      onRolled: (value) {
        rolledValue = value;
      },
    ));

    // Wait to ensure no roll happens
    await tester.pumpAndSettle();

    expect(rolledValue, equals(0));
  });
}