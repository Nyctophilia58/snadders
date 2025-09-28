import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:snadders/widgets/dice_roller.dart';
import 'package:snadders/widgets/exit_button.dart';
import '../services/ad_services/ad_banner_service.dart';
import '../services/ad_services/ad_interstitial_service.dart';
import 'data/ladders_data.dart';
import 'data/snakes_data.dart';

class PlayVsComputer extends StatefulWidget {
  final String username;
  final int boardIndex;

  const PlayVsComputer({super.key, required this.username, required this.boardIndex});

  @override
  State<PlayVsComputer> createState() => _PlayVsComputerState();
}

class _PlayVsComputerState extends State<PlayVsComputer> with SingleTickerProviderStateMixin {
  late List<int> playerPositions;
  int currentPlayerIndex = 0;
  String? winner;
  late AnimationController _winnerAnimationController;
  late Animation<double> _winnerAnimation;
  int get _boardNumber => widget.boardIndex + 1;

  @override
  void initState() {
    super.initState();
    playerPositions = [1, 1];
    _winnerAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _winnerAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _winnerAnimationController, curve: Curves.easeInOut),
    );
    AdBannerService.loadBannerAd();
  }

  @override
  void dispose() {
    _winnerAnimationController.dispose();
    super.dispose();
  }

  void handleDiceRoll(int playerIndex, int dice) {
    if (winner != null || currentPlayerIndex != playerIndex) return;

    setState(() {
      int newPosition = playerPositions[playerIndex] + dice;
      if (newPosition > 100) {
        currentPlayerIndex = (currentPlayerIndex + 1) % 2;
        return;
      }
      playerPositions[playerIndex] = newPosition;

      if (ladders_1.containsKey(playerPositions[playerIndex])) {
        playerPositions[playerIndex] = ladders_1[playerPositions[playerIndex]]!;
      } else if (snakes_1.containsKey(playerPositions[playerIndex])) {
        playerPositions[playerIndex] = snakes_1[playerPositions[playerIndex]]!;
      }

      if (playerPositions[playerIndex] == 100) {
        winner = playerIndex == 0 ? widget.username : "Computer";
        _winnerAnimationController.forward();
        _showWinnerDialog(winner!);
      } else {
        currentPlayerIndex = (currentPlayerIndex + 1) % 2;
      }
    });
  }

  void _showWinnerDialog(String winnerName) {
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
                      _resetGame();
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

  void _resetGame() {
    setState(() {
      playerPositions = [1, 1];
      currentPlayerIndex = 0;
      winner = null;
      _winnerAnimationController.reset();
    });
  }

  Offset getPositionOffset(int position, double cellWidth, double cellHeight, double padding) {
    int row = (position - 1) ~/ 10;
    int col = (position - 1) % 10;
    if (row % 2 == 1) col = 9 - col;
    double dx = padding + col * cellWidth + cellWidth / 2;
    double dy = (9 - row) * cellHeight + cellHeight / 2;
    return Offset(dx, dy);
  }

  Widget buildPlayerInfo(int playerIndex, String label, Color color) {
    Color textColor = Colors.yellow[700]!;

    return Column(
      crossAxisAlignment: playerIndex == 1 ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            if (currentPlayerIndex == playerIndex && winner == null && playerIndex == 1)
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.yellow, width: 2),
                ),
                child: DiceRoller(
                  onRolled: (dice) => handleDiceRoll(playerIndex, dice),
                  autoRoll: true,
                  delay: const Duration(seconds: 1),
                ),
              ),

            // Player/Computer icon
            Container(
              width: 45,
              height: 45,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.yellow, width: 2),
              ),
              child: Icon(Icons.location_on, color: Colors.white, size: 40),
            ),

            // Player dice on right
            if (currentPlayerIndex == playerIndex && winner == null && playerIndex == 0)
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.yellow, width: 2),
                ),
                child: DiceRoller(
                  onRolled: (dice) => handleDiceRoll(playerIndex, dice),
                  autoRoll: false,
                  delay: const Duration(seconds: 1),
                ),
              ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    const double imageWidth = 360.0;
    const double imageHeight = 500.0;
    const double imageAspect = imageWidth / imageHeight;
    const double boardPadding = 2.0;

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.greenAccent.shade200, Colors.blueAccent.shade400],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Stack(
            children: [
              // Board and tokens
              LayoutBuilder(
                builder: (context, constraints) {
                  double containerWidth = constraints.maxWidth - 2 * boardPadding;
                  double containerHeight = constraints.maxHeight;
                  double containerAspect = containerWidth / containerHeight;

                  double renderedWidth;
                  double renderedHeight;

                  if (containerAspect > imageAspect) {
                    renderedHeight = containerHeight;
                    renderedWidth = containerHeight * imageAspect;
                  } else {
                    renderedWidth = containerWidth;
                    renderedHeight = containerWidth / imageAspect;
                  }

                  double xOffset = (constraints.maxWidth - renderedWidth) / 2;
                  double yOffset = (containerHeight - renderedHeight) / 2;

                  double cellWidth = renderedWidth / 10;
                  double cellHeight = renderedHeight / 10;
                  double tokenSize = min(cellWidth, cellHeight) * 0.8;

                  return Stack(
                    children: [
                      SvgPicture.asset(
                        'assets/images/boards/$_boardNumber.svg',
                        width: containerWidth,
                        height: containerHeight,
                        fit: BoxFit.contain,
                      ),
                      ...List.generate(2, (index) {
                        Offset offset = getPositionOffset(playerPositions[index], cellWidth, cellHeight, boardPadding);
                        Color tokenColor = index == 0 ? Colors.green : Colors.red;
                        return Positioned(
                          left: offset.dx - tokenSize / 2 - xOffset,
                          top: yOffset + offset.dy - tokenSize / 2,
                          child: Icon(
                            Icons.location_on,
                            color: tokenColor,
                            size: tokenSize * 1.2,
                          ),
                        );
                      }),
                    ],
                  );
                },
              ),

              // Player/computer info row above bottom
              Positioned(
                left: 20,
                right: 20,
                bottom: 80, // adjust height here
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    buildPlayerInfo(0, "You", Colors.green),
                    buildPlayerInfo(1, "Computer", Colors.red),
                  ],
                ),
              ),

              // Exit button
              Positioned(
                bottom: 10,
                left: 10,
                child: ExitButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text("Exit Game"),
                          content: const Text("Are you sure you want to exit the game?"),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text("Cancel"),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                Navigator.of(context).pop();
                              },
                              child: const Text("Exit", style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
