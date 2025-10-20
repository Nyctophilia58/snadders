import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:snadders/game/board_selection.dart';
import 'package:snadders/pages/store_page.dart';
import 'package:snadders/services/iap_services.dart';

class MockIAPService extends Mock implements IAPService {}

void main() {
  late MockIAPService mockIapService;

  setUp(() {
    mockIapService = MockIAPService();
  });

  Future<void> _showBoardSelectorDialog(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            Future.microtask(() {
              showDialog(
                context: context,
                builder: (_) => BoardSelector(iapService: mockIapService),
              );
            });
            return const SizedBox();
          },
        ),
      ),
    );

    // Wait for dialog to appear
    await tester.pumpAndSettle();
  }

  testWidgets('Displays board image and lock overlay correctly', (tester) async {
    // Only board 0 unlocked
    when(() => mockIapService.unlockedBoardsNotifier)
        .thenReturn(ValueNotifier({0}));

    await _showBoardSelectorDialog(tester);

    // Board 0 unlocked -> no lock
    expect(find.byType(SvgPicture), findsOneWidget);
    expect(find.byIcon(Icons.lock), findsNothing);

    // Navigate to board 1 (locked)
    await tester.tap(find.byIcon(Icons.arrow_right));
    await tester.pump();

    expect(find.byIcon(Icons.lock), findsOneWidget);
  });

  testWidgets('Navigation buttons update board index', (tester) async {
    when(() => mockIapService.unlockedBoardsNotifier)
        .thenReturn(ValueNotifier({0}));

    await _showBoardSelectorDialog(tester);

    // Initial board
    expect(find.text('Board 1'), findsOneWidget);

    // Next board
    await tester.tap(find.byIcon(Icons.arrow_right));
    await tester.pump();
    expect(find.text('Board 2'), findsOneWidget);

    // Previous board
    await tester.tap(find.byIcon(Icons.arrow_left));
    await tester.pump();
    expect(find.text('Board 1'), findsOneWidget);
  });
}
