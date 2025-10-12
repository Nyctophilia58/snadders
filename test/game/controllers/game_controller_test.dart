import 'package:flutter_test/flutter_test.dart';
import 'package:snadders/game/controllers/game_controller.dart';

void main() {
  final testConfigs = {
    'PassNPlay': {
      'controller': () => GameController(
        totalPlayers: 4,
        boardNumber: 1,
        playerNames: ['Alice', 'Bob', 'Charlie', 'Diana'],
      ),
      'totalPlayers': 4,
      'playerNames': ['Alice', 'Bob', 'Charlie', 'Diana'],
    },
    'PlayVSComputer': {
      'controller': () => GameController(
        totalPlayers: 2,
        boardNumber: 1,
        playerNames: ['Alice', 'Computer'],
      ),
      'totalPlayers': 2,
      'playerNames': ['Alice', 'Computer'],
    },
  };

  testConfigs.forEach((name, config) {
    group('GameController($name) - ', () {
      late GameController controller;

      setUp(() {
        controller = (config['controller']! as Function)(); // ✅ call the function
      });

      test('Initial state is correct', () {
        expect(controller.totalPlayers, config['totalPlayers']);
        expect(controller.boardNumber, 1);
        expect(controller.playerNames, config['playerNames']);
        expect(controller.playerPositions, List.filled(controller.totalPlayers, 1));
        expect(controller.currentPlayerIndex, 0);
        expect(controller.winner, isNull);
      });

      test('Player can roll dice and move', () {
        controller.rollDice(0, 4);
        expect(controller.playerPositions[0], 5);
        expect(controller.currentPlayerIndex, 1 % controller.totalPlayers);

        controller.rollDice(1 % controller.totalPlayers, 3);
        expect(controller.playerPositions[1 % controller.totalPlayers], 4);
        expect(controller.currentPlayerIndex, 2 % controller.totalPlayers);
      });

      test('Cannot roll out of turn', () {
        controller.rollDice(1 % controller.totalPlayers, 3);
        expect(controller.playerPositions[1 % controller.totalPlayers], 1);
        expect(controller.currentPlayerIndex, 0);
      });

      test('Winning condition(100) is met', () {
        controller.playerPositions[0] = 97;
        controller.rollDice(0, 3);
        expect(controller.playerPositions[0], 100);
        expect(controller.winner, controller.playerNames[0]);
      });

      test('Rolling beyond 100 does not move the player', () {
        controller.playerPositions[0] = 98;
        controller.rollDice(0, 4);
        expect(controller.playerPositions[0], 98);
        expect(controller.winner, isNull);
      });

      test('No further moves after winning', () {
        controller.playerPositions[0] = 97;
        controller.rollDice(0, 3);
        controller.rollDice(1 % controller.totalPlayers, 3);
        expect(controller.playerPositions[1 % controller.totalPlayers], 1);
      });

      test('Resetting the game works', () {
        controller.playerPositions[0] = 50;
        controller.currentPlayerIndex = 2;
        controller.winner = controller.playerNames[0];

        controller.reset();
        expect(controller.playerPositions, List.filled(controller.totalPlayers, 1));
        expect(controller.currentPlayerIndex, 0);
        expect(controller.winner, isNull);
      });
    });
  });
}
