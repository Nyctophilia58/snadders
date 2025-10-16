import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:snadders/game/controllers/game_controller.dart';
import 'package:snadders/services/ad_services/ad_banner_service.dart';
import '../widgets/exit_button.dart';
import 'game_utils.dart';

class PlayVsComputer extends StatefulWidget {
  final String username;
  final int boardIndex;
  final bool allAdsRemoved;

  const PlayVsComputer({super.key, required this.username, required this.boardIndex, required this.allAdsRemoved});

  @override
  State<PlayVsComputer> createState() => _PlayVsComputerState();
}

class _PlayVsComputerState extends State<PlayVsComputer> with SingleTickerProviderStateMixin {
  late GameController controller;
  late AnimationController _winnerAnimationController;
  late Animation<double> _winnerAnimation;

  @override
  @override
  void initState() {
    super.initState();
    controller = GameController(
      totalPlayers: 2,
      boardNumber: widget.boardIndex + 1,
      playerNames: [widget.username, "Computer"],
    );

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
                      ...List.generate(2, (index) {
                        Offset offset = GameUtils.getPositionOffset(
                          controller.playerPositions[index],
                          cellWidth,
                          cellHeight,
                          boardPadding,
                        );
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

              // Player info row
              Positioned(
                left: 20,
                right: 20,
                bottom: 80,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GameUtils.buildPlayerInfo(
                      playerIndex: 0,
                      label: "You",
                      color: Colors.green,
                      currentPlayerIndex: controller.currentPlayerIndex,
                      autoRollDice: false,
                      onRolled: _handleDiceRoll,
                    ),
                    GameUtils.buildPlayerInfo(
                      playerIndex: 1,
                      label: "Computer",
                      color: Colors.red,
                      currentPlayerIndex: controller.currentPlayerIndex,
                      autoRollDice: true,
                      onRolled: _handleDiceRoll,
                      isComputer: true,
                    ),
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
