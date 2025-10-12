import 'package:flutter_test/flutter_test.dart';
import 'package:snadders/game/controllers/game_controller.dart';

void main() {
  late GameController controllerPass;
  late GameController controllerComputer;

  setUp(() {
    controllerComputer = GameController(
      totalPlayers: 2,
      boardNumber: 1,
      playerNames: ['Alice', 'Computer'],
    );
    controllerPass = GameController(
      totalPlayers: 4,
      boardNumber: 1,
      playerNames: ['Alice', 'Bob', 'Charlie', 'Diana'],
    );
  });

  group('GameController(PassNPlay) - ', () {
    test('Initial state is correct', () {
      expect(controllerPass.totalPlayers, 4);
      expect(controllerPass.boardNumber, 1);
      expect(controllerPass.playerNames, ['Alice', 'Bob', 'Charlie', 'Diana']);
      expect(controllerPass.playerPositions, [1, 1, 1, 1]);
      expect(controllerPass.currentPlayerIndex, 0);
      expect(controllerPass.winner, isNull);
    });

    test('Player can roll dice and move', () {
      controllerPass.rollDice(0, 4); // Alice rolls a 4
      expect(controllerPass.playerPositions[0], 5);
      expect(controllerPass.currentPlayerIndex, 1); // Next turn to Bob

      controllerPass.rollDice(1, 3); // Bob rolls a 3
      expect(controllerPass.playerPositions[1], 4);
      expect(controllerPass.currentPlayerIndex, 2); // Next turn to Charlie

      controllerPass.rollDice(2, 5); // Charlie rolls a 5
      expect(controllerPass.playerPositions[2], 27); // Lands on ladder from 6 to 27
      expect(controllerPass.currentPlayerIndex, 3); // Next turn to Diana

      controllerPass.rollDice(3, 1); // Charlie rolls a 1
      expect(controllerPass.playerPositions[3], 2);
      expect(controllerPass.currentPlayerIndex, 0); // Next turn to Alice
    });

    test('Cannot roll out of turn', () {
      controllerPass.rollDice(1, 3); // Bob tries to roll out of turn
      expect(controllerPass.playerPositions[1], 1); // Position should not change
      expect(controllerPass.currentPlayerIndex, 0); // Still Alice's turn
    });

    test('Winning condition(100) is met', () {
      controllerPass.playerPositions[0] = 97; // Set Alice close to winning
      controllerPass.rollDice(0, 3); // Alice rolls a 4 to win
      expect(controllerPass.playerPositions[0], 100); // Alice should be at position 100
      expect(controllerPass.winner, 'Alice'); // Alice should be the winner
    });

    test('Rolling beyond 100 does not move the player', () {
      controllerPass.playerPositions[0] = 98; // Set Alice close to winning
      controllerPass.rollDice(0, 4); // Alice rolls a 4, which would exceed 100
      expect(controllerPass.playerPositions[0], 98); // Alice should remain at position 98
      expect(controllerPass.winner, isNull); // No winner yet
    });

    test('No further moves after winning', () {
      controllerPass.playerPositions[0] = 97;
      controllerPass.rollDice(0, 3); // Alice wins
      controllerPass.rollDice(1, 3); // Bob tries to roll after game over
      expect(controllerPass.playerPositions[1], 1); // Bob's position should not change
    });

    test('Resetting the game works', () {
      controllerPass.playerPositions[0] = 50;
      controllerPass.currentPlayerIndex = 2;
      controllerPass.winner = 'Alice';

      controllerPass.reset();
      expect(controllerPass.playerPositions, [1, 1, 1, 1]);
      expect(controllerPass.currentPlayerIndex, 0);
      expect(controllerPass.winner, isNull);
    });
  });

  group('GameController(PlayVSComputer) - ', () {
    test('Initial state is correct', () {
      expect(controllerComputer.totalPlayers, 2);
      expect(controllerComputer.boardNumber, 1);
      expect(controllerComputer.playerNames, ['Alice', 'Computer']);
      expect(controllerComputer.playerPositions, [1, 1]);
      expect(controllerComputer.currentPlayerIndex, 0);
      expect(controllerComputer.winner, isNull);
    });

    test('Player can roll dice and move', () {
      controllerComputer.rollDice(0, 4);
      expect(controllerComputer.playerPositions[0], 5);
      expect(controllerComputer.currentPlayerIndex, 1);

      controllerComputer.rollDice(1, 3);
      expect(controllerComputer.playerPositions[1], 4);
      expect(controllerComputer.currentPlayerIndex, 0);
    });

    test('Cannot roll out of turn', () {
      controllerComputer.rollDice(1, 3);
      expect(controllerComputer.playerPositions[1], 1);
      expect(controllerComputer.currentPlayerIndex, 0);
    });

    test('Winning condition(100) is met', () {
      controllerComputer.playerPositions[0] = 97;
      controllerComputer.rollDice(0, 3);
      expect(controllerComputer.playerPositions[0], 100);
      expect(controllerComputer.winner, 'Alice');
    });

    test('Rolling beyond 100 does not move the player', () {
      controllerComputer.rollDice(0, 3);
      expect(controllerComputer.playerPositions[0], 4);
      expect(controllerComputer.winner, null);
    });

    test('No further moves after winning', () {
      controllerComputer.playerPositions[0] = 97;
      controllerComputer.rollDice(0, 3);
      controllerComputer.rollDice(1, 3);
      expect(controllerComputer.playerPositions[1], 1);
    });

    test('Resetting the game works', () {
      controllerComputer.playerPositions[0] = 50;
      controllerComputer.currentPlayerIndex = 1;
      controllerComputer.winner = 'Alice';

      controllerComputer.reset();
      expect(controllerComputer.playerPositions, [1, 1]);
      expect(controllerComputer.currentPlayerIndex, 0);
      expect(controllerComputer.winner, isNull);
    });
  });
}