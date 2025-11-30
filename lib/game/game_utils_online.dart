import 'package:flutter/material.dart';
import '../services/shared_prefs_service.dart';
import '../widgets/dice_roller.dart';
import '../services/ad_services/ad_banner_service.dart';
import '../services/ad_services/ad_interstitial_service.dart';
import 'data/ladders_data.dart';
import 'data/snakes_data.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:lottie/lottie.dart';

typedef DiceRollCallback = void Function(int playerIndex, int dice);
typedef VoidCallback = void Function();

class GameUtilsOnline {
  /// Handles dice roll, snakes/ladders, winner check
  static void handleDiceRoll({
    required int playerIndex,
    required List<int> playerPositions,
    required int dice,
    required int totalPlayers,
    required int boardIndex,
    required Function(int newCurrentPlayerIndex) updateCurrentPlayer,
    required Function(String winnerName) onWinner,
  }) {
    int newPosition = playerPositions[playerIndex] + dice;
    if (newPosition > 100) {
      updateCurrentPlayer((playerIndex + 1) % totalPlayers);
      return;
    }

    playerPositions[playerIndex] = newPosition;

    Map<int, int> ladders = laddersList[boardIndex - 1];
    Map<int, int> snakes = snakesList[boardIndex - 1];

    if (ladders.containsKey(playerPositions[playerIndex])) {
      playerPositions[playerIndex] = ladders[playerPositions[playerIndex]]!;
    } else if (snakes.containsKey(playerPositions[playerIndex])) {
      playerPositions[playerIndex] = snakes[playerPositions[playerIndex]]!;
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

  /// Build player info widget with correct dice placement
  static Widget buildPlayerInfo({
    required int playerIndex,
    required String label,
    required Color color,
    required int currentPlayerIndex,
    required bool autoRollDice,
    required DiceRollCallback onRolled,
    required String profileImage,
    required int myPlayerIndex,
    bool isComputer = false,
    // Sync props
    String? diceRollTrigger,
    int? forcedDiceValue,
  }) {
    bool isCurrent = currentPlayerIndex == playerIndex;
    bool isLocal = playerIndex == myPlayerIndex;

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
        autoRoll: autoRollDice,
        delay: const Duration(milliseconds: 500),
        isInteractive: isCurrent && isLocal,
        diceRollTrigger: diceRollTrigger,
        forcedDiceValue: forcedDiceValue,
      ),
    );

    // show dice for current player only
    List<Widget> rowChildren = [];
    if (isCurrent) {
      if (playerIndex == 1 || playerIndex == 2) rowChildren.add(diceWidget);
    }

    // Replace location icon with profile image
    rowChildren.add(Container(
      width: 45,
      height: 45,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.yellow, width: 2),
        image: DecorationImage(
          image: AssetImage(profileImage),
          fit: BoxFit.cover,
        ),
      ),
    ));

    if (isCurrent) {
      if (playerIndex == 0 || playerIndex == 3) rowChildren.add(diceWidget);
    }

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
    required String winnerUid,
    required SharedPrefsService service,
    required VoidCallback onPlayAgain,
    required VoidCallback onExit,
    required bool allAdsRemoved,
  }) {
    final AudioPlayer audioPlayer = AudioPlayer();
    audioPlayer.play(AssetSource('audios/success-48729.mp3'));

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Stack(
          children: [
            // Full-screen Lottie animation
            Lottie.asset(
              'assets/animations/confetti.json',
              height: 700,
              width: 400,
              fit: BoxFit.cover,
              repeat: false,
            ),
            // Dialog content at the bottom with white background
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Padding(
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
                      if (!allAdsRemoved && AdBannerService.getBannerWidget() != null)
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
                              audioPlayer.stop();
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
                            onPressed: () async {
                              Navigator.pop(context);
                              audioPlayer.stop();
                              onExit();
                              await service.saveGamesPlayed(await service.loadGamesPlayed() + 1);
                              await service.saveGamesWon(
                                winnerUid == await service.loadUserId()
                                    ? await service.loadGamesWon() + 1
                                    : await service.loadGamesWon(),
                              );
                              await service.saveWinRate(
                                await service.calculateWinRate(),
                              );
                              if (!allAdsRemoved) {
                                AdInterstitialService.showInterstitialAd();
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}