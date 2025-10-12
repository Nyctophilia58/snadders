import '../game_utils.dart';

class GameController {
  final int totalPlayers;
  final int boardNumber;
  final List<String> playerNames;

  late List<int> playerPositions;
  int currentPlayerIndex = 0;
  String? winner;

  GameController({
    required this.totalPlayers,
    required this.boardNumber,
    required this.playerNames,
  }) {
    assert(playerNames.length == totalPlayers, "playerNames length must match totalPlayers");
    playerPositions = List<int>.filled(totalPlayers, 1);
  }

  /// Roll dice and update game state
  void rollDice(int playerIndex, int dice) {
    if (winner != null || currentPlayerIndex != playerIndex) return;

    GameUtils.handleDiceRoll(
      playerIndex: playerIndex,
      playerPositions: playerPositions,
      dice: dice,
      totalPlayers: totalPlayers,
      boardIndex: boardNumber,
      updateCurrentPlayer: (newIndex) => currentPlayerIndex = newIndex,
      onWinner: (_) => winner = playerNames[playerIndex],
    );
  }

  /// Reset game to initial state
  void reset() {
    playerPositions = List<int>.filled(totalPlayers, 1);
    currentPlayerIndex = 0;
    winner = null;
  }
}
