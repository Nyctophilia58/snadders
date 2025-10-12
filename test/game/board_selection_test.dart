import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:snadders/game/board_selection.dart';
import 'package:mocktail/mocktail.dart';
import 'package:snadders/game/controllers/board_selector_controller.dart';

class MockBoardSelectorController extends Mock implements BoardSelectorController {}

void main() {
  // Instantiate the mock controller
  late MockBoardSelectorController mockController;

  setUp(() {
    // Initialize the mock controller before each test
    mockController = MockBoardSelectorController();

    // Default mock behavior for tests. This process called stubbing.
    when(() => mockController.currentBoardIndex).thenReturn(0);
    when(() => mockController.loadUnlockedBoards())
        .thenAnswer((_) async => [true, false, false, false, false, false, false, false]);
  });

  testWidgets('Shows CircularProgressIndicator when loading', (tester) async {
    // Use a controller that delays
    final controller = MockBoardSelectorController();
    when(() => controller.loadUnlockedBoards()).thenAnswer((_) => Future.delayed(Duration(seconds: 1), () => [true]));

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => BoardSelector(key: Key('board_selector')),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
