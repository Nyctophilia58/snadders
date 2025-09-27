import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:snadders/widgets/dice_roller.dart';
import 'package:snadders/widgets/exit_button.dart';
import '../services/ad_services/ad_banner_service.dart';
import '../services/ad_services/ad_interstitial_service.dart';

class PlayVsComputer extends StatefulWidget {
  final String username;

  const PlayVsComputer({super.key, required this.username});

  @override
  State<PlayVsComputer> createState() => _PlayVsComputerState();
}

class _PlayVsComputerState extends State<PlayVsComputer> with SingleTickerProviderStateMixin {
  late List<int> playerPositions;
  int currentPlayerIndex = 0;
  String? winner;
  late AnimationController _winnerAnimationController;
  late Animation<double> _winnerAnimation;

  final Map<int, int> ladders = {8: 47, 16: 35, 21: 39, 41: 82, 51: 69, 65: 86};
  final Map<int, int> snakes = {24: 17, 48: 31, 54: 45, 58: 37, 93: 53, 96: 63};
  final List<Color> playerColors = [Colors.red, Colors.green];
  final List<String> playerTokenPaths = [
    'assets/images/tokens/red.png',
    'assets/images/tokens/green.png',
  ];

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

  void handleDiceRoll(int dice) {
    if (winner != null) return;
    setState(() {
      int newPosition = playerPositions[currentPlayerIndex] + dice;
      if (newPosition > 100) {
        currentPlayerIndex = (currentPlayerIndex + 1) % 2;
        return;
      }
      playerPositions[currentPlayerIndex] = newPosition;

      if (ladders.containsKey(playerPositions[currentPlayerIndex])) {
        playerPositions[currentPlayerIndex] = ladders[playerPositions[currentPlayerIndex]]!;
      } else if (snakes.containsKey(playerPositions[currentPlayerIndex])) {
        playerPositions[currentPlayerIndex] = snakes[playerPositions[currentPlayerIndex]]!;
      }

      if (playerPositions[currentPlayerIndex] == 100) {
        winner = currentPlayerIndex == 0 ? widget.username : "Computer";
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

    if (row % 2 == 1) {
      col = 9 - col;
    }

    double dx = padding + col * cellWidth + cellWidth / 2;
    double dy = (9 - row) * cellHeight + cellHeight / 2;

    return Offset(dx, dy);
  }

  Widget buildPlayerInfo(int playerIndex, String label, Color color) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Card(
        elevation: currentPlayerIndex == playerIndex && winner == null ? 8 : 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(12),
          width: 160,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withOpacity(0.1), color.withOpacity(0.3)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: currentPlayerIndex == playerIndex && winner == null
                ? color.withOpacity(0.8)
                : Colors.transparent,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: color,
                child: Icon(Icons.person, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Roboto',
                  ),
                ),
              ),
              if (currentPlayerIndex == playerIndex && winner == null)
                const Icon(Icons.arrow_forward_ios, color: Colors.green, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const double imageWidth = 360.0;
    const double imageHeight = 500.0;
    const double imageAspect = imageWidth / imageHeight;
    const double boardPadding = 24.0;

    return WillPopScope(
      onWillPop: () async => false, // Disable system back
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.teal.shade100, Colors.blue.shade300],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    flex: 3,
                    child: LayoutBuilder(
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

                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: boardPadding),
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 12,
                                spreadRadius: 4,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              SvgPicture.asset(
                                'assets/images/boards/premium03.svg',
                                width: containerWidth,
                                height: containerHeight,
                                fit: BoxFit.contain,
                              ),
                              ...List.generate(2, (index) {
                                Offset offset = getPositionOffset(playerPositions[index], cellWidth, cellHeight, boardPadding);
                                return Positioned(
                                  left: offset.dx - tokenSize / 2 - xOffset,
                                  top: yOffset + offset.dy - tokenSize / 2,
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    width: tokenSize,
                                    height: tokenSize,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                        image: AssetImage(playerTokenPaths[index]),
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        if (winner == null)
                          DiceRoller(
                            onRolled: handleDiceRoll,
                            autoRoll: currentPlayerIndex != 0,
                            delay: const Duration(seconds: 1),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              // Player info
              Positioned(
                bottom: 160,
                left: 20,
                child: buildPlayerInfo(0, widget.username, playerColors[0]),
              ),
              Positioned(
                bottom: 160,
                right: 20,
                child: buildPlayerInfo(1, "Computer", playerColors[1]),
              ),
              Positioned(
                top: 10,
                right: 10,
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
                                Navigator.of(context).pop(); // Close dialog
                                Navigator.of(context).pop(); // Exit game screen
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
