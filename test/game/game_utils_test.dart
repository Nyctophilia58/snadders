import 'package:flutter_test/flutter_test.dart';
import 'package:snadders/game/game_utils.dart';

void main() {
  group('GameUtils.handleDiceRoll', () {
    test('Player moves correctly and turn updates', () {
      List<int> positions = [1, 1];
      int currentPlayer = 0;
      String? winner;

      GameUtils.handleDiceRoll(
        playerIndex: 0,
        playerPositions: positions,
        dice: 4,
        totalPlayers: 2,
        boardIndex: 1,
        updateCurrentPlayer: (newIndex) => currentPlayer = newIndex,
        onWinner: (winnerName) => winner = winnerName,
      );

      expect(positions[0], 5);
      expect(currentPlayer, 1);
      expect(winner, isNull);
    });

    test('Player cannot exceed 100', () {
      List<int> positions = [98, 1];
      int currentPlayer = 0;
      String? winner;

      GameUtils.handleDiceRoll(
        playerIndex: 0,
        playerPositions: positions,
        dice: 5,
        totalPlayers: 2,
        boardIndex: 1,
        updateCurrentPlayer: (newIndex) => currentPlayer = newIndex,
        onWinner: (winnerName) => winner = winnerName,
      );

      // Should not move
      expect(positions[0], 98);
      // Turn should pass to next player
      expect(currentPlayer, 1);
      expect(winner, isNull);
    });

    test('Player wins when reaching 100', () {
      List<int> positions = [97, 1];
      int currentPlayer = 0;
      String? winner;

      GameUtils.handleDiceRoll(
        playerIndex: 0,
        playerPositions: positions,
        dice: 3,
        totalPlayers: 2,
        boardIndex: 1,
        updateCurrentPlayer: (newIndex) => currentPlayer = newIndex,
        onWinner: (winnerName) => winner = winnerName,
      );

      expect(positions[0], 100);
      expect(winner, "Player 1");
    });
  });

  group('GameUtils.getPositionOffset', () {
    test('Correct offset for normal row', () {
      final offset = GameUtils.getPositionOffset(1, 10, 10, 2);
      expect(offset.dx, 2 + 0 * 10 + 5);
      expect(offset.dy, 9 * 10 + 5);
    });

    test('Correct offset for reversed row', () {
      final offset = GameUtils.getPositionOffset(12, 10, 10, 2); // row 1, reversed
      expect(offset.dx, 2 + (9 - 1) * 10 + 5); // col 1 reversed
      expect(offset.dy, (9 - 1) * 10 + 5); // row 1
    });
  });
}
