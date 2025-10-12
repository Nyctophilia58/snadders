import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:snadders/constants/board_constants.dart';
import 'package:snadders/game/controllers/board_selector_controller.dart';
import 'package:snadders/services/shared_prefs_service.dart';

// Mock class for SharedPrefsService
class MockSharedPrefsService extends Mock implements SharedPrefsService {}

void main() {
  // Instance controller and mock service
  late BoardSelectorController controller;
  late MockSharedPrefsService mockPrefs;

  setUp(() {
    // Initialize mock and controller before each test
    mockPrefs = MockSharedPrefsService();
    controller = BoardSelectorController(prefsService: mockPrefs);
  });

  group('BoardSelectorController - ', () {
    test('Initial currentBoardIndex should be 0', () {
      expect(controller.currentBoardIndex, 0);
    });

    test('NextBoard should increment currentBoardIndex and wrap around', () {
      final totalBoards = boardImages.length;

      controller.currentBoardIndex = totalBoards - 1;
      controller.nextBoard();

      // should wrap back to 0
      expect(controller.currentBoardIndex, 0);
    });

    test('PrevBoard should decrement currentBoardIndex and wrap around', () {
      controller.currentBoardIndex = 0;
      controller.prevBoard();

      // should wrap back to last board
      expect(controller.currentBoardIndex, boardImages.length - 1);
    });

    test('LoadUnlockedBoards should respect defaultUnlockedBoards and prefs', () async {
      // Arrange: fake prefs values
      when(() => mockPrefs.loadBoardUnlocked(any())).thenAnswer((_) async => false);
      when(() => mockPrefs.loadBoardUnlocked(3)).thenAnswer((_) async => true); // simulate unlocked board 3

      // Act
      final boards = await controller.loadUnlockedBoards();

      // Assert
      expect(boards.length, boardImages.length);

      for (int i = 0; i < boardImages.length; i++) {
        if (i < defaultUnlockedBoards) {
          expect(boards[i], true, reason: 'Board $i should be unlocked by default');
        } else if (i == 3) {
          expect(boards[i], true, reason: 'Board 3 should be unlocked via prefs');
        } else {
          expect(boards[i], false, reason: 'Board $i should remain locked');
        }
      }
    });
  });
}
