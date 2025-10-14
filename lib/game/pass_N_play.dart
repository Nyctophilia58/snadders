import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:snadders/game/controllers/game_controller.dart';
import '../widgets/exit_button.dart';
import 'game_utils.dart';

class PassNPlay extends StatefulWidget {
  final int selectedPlayers;
  final int boardIndex;
  final bool allAdsRemoved;

  const PassNPlay({super.key, required this.selectedPlayers, required this.boardIndex, required this.allAdsRemoved});

  @override
  State<PassNPlay> createState() => _PassNPlayState();
}

class _PassNPlayState extends State<PassNPlay> with SingleTickerProviderStateMixin {
  late GameController controller;
  late AnimationController _winnerAnimationController;
  late Animation<double> _winnerAnimation;

  final List<Color> playerColors = [Colors.green, Colors.red, Colors.yellow, Colors.blue];

  @override
  void initState() {
    super.initState();
    controller = GameController(
      totalPlayers: widget.selectedPlayers,
      boardNumber: widget.boardIndex + 1,
      playerNames: List.generate(widget.selectedPlayers, (i) => "Player ${i + 1}"),
    );


    _winnerAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _winnerAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _winnerAnimationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _winnerAnimationController.dispose();
    super.dispose();
  }

  void _handleDiceRoll(int playerIndex, int dice) {
    if (controller.winner != null || controller.currentPlayerIndex != playerIndex) return;

    setState(() {
      controller.rollDice(playerIndex, dice);

      if (controller.winner != null) {
        _winnerAnimationController.forward();
        GameUtils.showWinnerDialog(
          context: context,
          winnerName: controller.winner!,
          onPlayAgain: _resetGame,
          allAdsRemoved: widget.allAdsRemoved,
        );
      }
    });
  }

  void _resetGame() {
    setState(() {
      controller.reset();
      _winnerAnimationController.reset();
    });
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
                        'assets/images/boards/${widget.boardIndex + 1}.svg',
                        width: containerWidth,
                        height: containerHeight,
                        fit: BoxFit.contain,
                      ),
                      ...List.generate(widget.selectedPlayers, (index) {
                        Offset offset = GameUtils.getPositionOffset(controller.playerPositions[index], cellWidth, cellHeight, boardPadding);
                        return Positioned(
                          left: offset.dx - tokenSize / 2 - xOffset,
                          top: yOffset + offset.dy - tokenSize / 2,
                          child: Icon(
                            Icons.location_on,
                            color: playerColors[index],
                            size: tokenSize,
                          ),
                        );
                      }),
                    ],
                  );
                },
              ),

              // Player info
              Positioned(bottom: 80, left: 20, child: GameUtils.buildPlayerInfo(
                playerIndex: 0,
                label: "Player 1",
                color: playerColors[0],
                currentPlayerIndex: controller.currentPlayerIndex,
                autoRollDice: false,
                onRolled: _handleDiceRoll,
              )),
              if (widget.selectedPlayers >= 2)
                Positioned(bottom: 80, right: 20, child: GameUtils.buildPlayerInfo(
                  playerIndex: 1,
                  label: "Player 2",
                  color: playerColors[1],
                  currentPlayerIndex: controller.currentPlayerIndex,
                  autoRollDice: false,
                  onRolled: _handleDiceRoll,
                )),
              if (widget.selectedPlayers >= 3)
                Positioned(top: 70, right: 20, child: GameUtils.buildPlayerInfo(
                  playerIndex: 2,
                  label: "Player 3",
                  color: playerColors[2],
                  currentPlayerIndex: controller.currentPlayerIndex,
                  autoRollDice: false,
                  onRolled: _handleDiceRoll,
                )),
              if (widget.selectedPlayers >= 4)
                Positioned(top: 70, left: 20, child: GameUtils.buildPlayerInfo(
                  playerIndex: 3,
                  label: "Player 4",
                  color: playerColors[3],
                  currentPlayerIndex: controller.currentPlayerIndex,
                  autoRollDice: false,
                  onRolled: _handleDiceRoll,
                )),

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
