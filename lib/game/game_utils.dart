import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../widgets/dice_roller.dart';
import '../services/ad_services/ad_banner_service.dart';
import '../services/ad_services/ad_interstitial_service.dart';
import 'data/ladders_data.dart';
import 'data/snakes_data.dart';

typedef DiceRollCallback = void Function(int playerIndex, int dice);

class GameUtils {
  /// Handles dice roll, snakes/ladders, winner check
  static void handleDiceRoll({
    required int playerIndex,
    required List<int> playerPositions,
    required int dice,
    required int totalPlayers,
    required Function(int newCurrentPlayerIndex) updateCurrentPlayer,
    required Function(String winnerName) onWinner,
  }) {
    int newPosition = playerPositions[playerIndex] + dice;
    if (newPosition > 100) {
      updateCurrentPlayer((playerIndex + 1) % totalPlayers);
      return;
    }

    playerPositions[playerIndex] = newPosition;

    if (ladders_1.containsKey(playerPositions[playerIndex])) {
      playerPositions[playerIndex] = ladders_1[playerPositions[playerIndex]]!;
    } else if (snakes_1.containsKey(playerPositions[playerIndex])) {
      playerPositions[playerIndex] = snakes_1[playerPositions[playerIndex]]!;
    }

    if (playerPositions[playerIndex] == 100) {
      onWinner("Player ${playerIndex + 1}");
    } else {
      updateCurrentPlayer((playerIndex + 1) % totalPlayers);
    }
  }

  /// Calculates offset of token based on board position
  static Offset getPositionOffset(int position, double cellWidth, double cellHeight, double padding) {
    int row = (position - 1) ~/ 10;
    int col = (position - 1) % 10;
    if (row % 2 == 1) col = 9 - col;
    double dx = padding + col * cellWidth + cellWidth / 2;
    double dy = (9 - row) * cellHeight + cellHeight / 2;
    return Offset(dx, dy);
  }

  /// Build player info widget
  /// Build player info widget with correct dice placement
  static Widget buildPlayerInfo({
    required int playerIndex,
    required String label,
    required Color color,
    required int currentPlayerIndex,
    required bool autoRollDice,
    required DiceRollCallback onRolled,
    bool isComputer = false,
  }) {
    bool isCurrent = currentPlayerIndex == playerIndex;

    // Dice widget
    Widget diceWidget = Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: (playerIndex == 1 || playerIndex == 2) ? Colors.white.withOpacity(0.1) : null,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.yellow, width: 2),
      ),
      child: DiceRoller(
        onRolled: (dice) => onRolled(playerIndex, dice),
        autoRoll: isComputer && isCurrent,
        delay: const Duration(seconds: 1),
      ),
    );

    // Row children based on original placement logic
    List<Widget> rowChildren = [];
    if (isCurrent && (playerIndex == 1 || playerIndex == 2)) rowChildren.add(diceWidget);
    rowChildren.add(Container(
      width: 45,
      height: 45,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.yellow, width: 2),
      ),
      child: const Icon(Icons.location_on, color: Colors.white, size: 40),
    ));
    if (isCurrent && (playerIndex == 0 || playerIndex == 3)) rowChildren.add(diceWidget);

    return Column(
      crossAxisAlignment: (playerIndex == 1 || playerIndex == 2)
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.yellow[700],
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 6),
        Row(mainAxisSize: MainAxisSize.min, children: rowChildren),
      ],
    );
  }

  /// Show winner dialog
  static void showWinnerDialog({
    required BuildContext context,
    required String winnerName,
    required VoidCallback onPlayAgain,
  }) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "$winnerName wins!",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 20),
              if (AdBannerService.getBannerWidget() != null)
                AdBannerService.getBannerWidget()!,
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    label: const Text("Play Again", style: TextStyle(color: Colors.white)),
                    onPressed: () {
                      Navigator.pop(context);
                      onPlayAgain();
                    },
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.exit_to_app, color: Colors.white),
                    label: const Text("Exit", style: TextStyle(color: Colors.white)),
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                      AdInterstitialService.showInterstitialAd();
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
