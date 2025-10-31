import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:snadders/game/controllers/game_controller.dart';
import 'package:snadders/services/ad_services/ad_banner_service.dart';
import '../widgets/exit_button.dart';
import 'data/ladders_data.dart';
import 'data/snakes_data.dart';
import 'game_utils.dart';

class PlayVsComputer extends StatefulWidget {
  final String username;
  final int boardIndex;
  final bool allAdsRemoved;

  const PlayVsComputer({super.key, required this.username, required this.boardIndex, required this.allAdsRemoved});

  @override
  State<PlayVsComputer> createState() => _PlayVsComputerState();
}

class _PlayVsComputerState extends State<PlayVsComputer> with TickerProviderStateMixin {
  late GameController controller;
  late AnimationController _winnerAnimationController;
  late Animation<double> _winnerAnimation;

  // Animation controllers for each token
  late List<AnimationController> _tokenControllers;
  late List<Animation<Offset>> _tokenAnimations;
  late List<Animation<double>> _tokenRotations;
  bool _isAnimating = false;

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

    _tokenControllers = List.generate(
      2,
          (_) => AnimationController(vsync: this, duration: const Duration(milliseconds: 1000)),
    );
    _tokenAnimations = List.generate(2, (_) => AlwaysStoppedAnimation(Offset.zero));
    _tokenRotations = List.generate(2, (_) => AlwaysStoppedAnimation(0.0));

    AdBannerService.loadBannerAd();
  }

  @override
  void dispose() {
    for (var c in _tokenControllers) c.dispose();
    _winnerAnimationController.dispose();
    super.dispose();
  }

  void _handleDiceRoll(int playerIndex, int dice) async {
    if (_isAnimating || controller.winner != null || controller.currentPlayerIndex != playerIndex) return;

    _isAnimating = true;
    int oldPosition = controller.playerPositions[playerIndex];
    int newPosition = oldPosition + dice;

    if (newPosition > 100) {
      controller.currentPlayerIndex = (playerIndex + 1) % 2;
      _isAnimating = false;
      setState(() {});
      return;
    }

    // Per-square hop animation
    for (int pos = oldPosition + 1; pos <= newPosition; pos++) {
      await _animateTokenHop(playerIndex, pos);
    }

    // Handle ladder/snake
    final ladders = laddersList[controller.boardNumber - 1];
    final snakes = snakesList[controller.boardNumber - 1];

    if (ladders.containsKey(newPosition)) {
      int end = ladders[newPosition]!;
      await _animateLadder(playerIndex, newPosition, end);
      controller.playerPositions[playerIndex] = end;
    } else if (snakes.containsKey(newPosition)) {
      int end = snakes[newPosition]!;
      await _animateSnake(playerIndex, newPosition, end);
      controller.playerPositions[playerIndex] = end;
    } else {
      controller.playerPositions[playerIndex] = newPosition;
    }

    // Check winner
    if (controller.playerPositions[playerIndex] == 100) {
      controller.winner = controller.playerNames[playerIndex];
      _winnerAnimationController.forward();
      GameUtils.showWinnerDialog(
        context: context,
        winnerName: controller.winner!,
        onPlayAgain: _resetGame,
        allAdsRemoved: widget.allAdsRemoved,
      );
    } else {
      controller.currentPlayerIndex = (playerIndex + 1) % 2;
    }

    _isAnimating = false;
    setState(() {});
  }

  Future<void> _animateTokenHop(int index, int targetPosition) async {
    final animCtrl = _tokenControllers[index];

    final Offset startOffset = _getCellOffset(controller.playerPositions[index]);
    final Offset endOffset = _getCellOffset(targetPosition);

    _tokenAnimations[index] = Tween<Offset>(
      begin: startOffset,
      end: endOffset,
    ).animate(CurvedAnimation(parent: animCtrl, curve: Curves.linear));

    // Add a parabolic hop effect via listener
    animCtrl.addListener(() {
      setState(() {
        double t = animCtrl.value; // 0 -> 1
        double hopHeight = 20; // pixels to jump up
        double verticalOffset = 4 * hopHeight * t * (t - 1);
        _tokenAnimations[index] = AlwaysStoppedAnimation(
          Offset(
            startOffset.dx + (endOffset.dx - startOffset.dx) * t,
            startOffset.dy + (endOffset.dy - startOffset.dy) * t + verticalOffset,
          ),
        );
      });
    });

    animCtrl.reset();
    animCtrl.duration = const Duration(milliseconds: 300);
    await animCtrl.forward();

    // Update final position in game controller
    controller.playerPositions[index] = targetPosition;
    setState(() {});
  }

  Future<void> _animateLadder(int index, int start, int end) async {
    final animCtrl = _tokenControllers[index];
    final Offset startOffset = _getCellOffset(start);
    final Offset endOffset = _getCellOffset(end);

    animCtrl.addListener(() {
      setState(() {
        double t = animCtrl.value;
        double hopHeight = 25;
        double verticalOffset = -4 * hopHeight * t * (t - 1);
        _tokenAnimations[index] = AlwaysStoppedAnimation(
          Offset(
            startOffset.dx + (endOffset.dx - startOffset.dx) * t,
            startOffset.dy + (endOffset.dy - startOffset.dy) * t + verticalOffset,
          ),
        );
      });
    });

    animCtrl.reset();
    animCtrl.duration = const Duration(milliseconds: 700);
    await animCtrl.forward();
    controller.playerPositions[index] = end;
    setState(() {});
  }

  Future<void> _animateSnake(int index, int start, int end, {int maxSpins = 6}) async {
    final animCtrl = _tokenControllers[index];
    final rotationCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    final Offset startOffset = _getCellOffset(start);
    final Offset endOffset = _getCellOffset(end);

    int distance = (start - end).abs(); // number of squares snake covers
    int spins = ((distance / 10) * maxSpins).clamp(1, maxSpins).toInt();

    // Horizontal + vertical slide
    animCtrl.addListener(() {
      setState(() {
        double t = animCtrl.value;
        double hopHeight = 10; // subtle arc
        double verticalOffset = -4 * hopHeight * t * (t - 1);
        _tokenAnimations[index] = AlwaysStoppedAnimation(
          Offset(
            startOffset.dx + (endOffset.dx - startOffset.dx) * t,
            startOffset.dy + (endOffset.dy - startOffset.dy) * t + verticalOffset,
          ),
        );
      });
    });

    // Rotation based on distance
    _tokenRotations[index] = Tween<double>(begin: 0, end: spins * 2 * pi).animate(
      CurvedAnimation(parent: rotationCtrl, curve: Curves.linear),
    );

    animCtrl.reset();
    rotationCtrl.reset();
    animCtrl.duration = const Duration(milliseconds: 900);
    rotationCtrl.duration = const Duration(milliseconds: 900);

    await Future.wait([animCtrl.forward(), rotationCtrl.forward()]);

    controller.playerPositions[index] = end;
    rotationCtrl.dispose();
    setState(() {});
  }

  Offset _getCellOffset(int position) {
    const boardPadding = 2.0;
    final constraints = MediaQuery.of(context).size;
    const imageAspect = 360.0 / 500.0;
    double containerWidth = constraints.width - 2 * boardPadding;
    double containerHeight = constraints.height;
    double containerAspect = containerWidth / containerHeight;

    double renderedWidth, renderedHeight;
    if (containerAspect > imageAspect) {
      renderedHeight = containerHeight;
      renderedWidth = containerHeight * imageAspect;
    } else {
      renderedWidth = containerWidth;
      renderedHeight = containerWidth / imageAspect;
    }

    double cellWidth = renderedWidth / 10;
    double cellHeight = renderedHeight / 10;

    return GameUtils.getPositionOffset(position, cellWidth, cellHeight, boardPadding);
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
                        return AnimatedBuilder(
                          animation: _tokenControllers[index],
                          builder: (context, child) {
                            Offset base = GameUtils.getPositionOffset(
                              controller.playerPositions[index],
                              cellWidth,
                              cellHeight,
                              boardPadding,
                            );
                            Offset animated = _tokenAnimations[index].value;
                            double rotation = _tokenRotations[index].value;

                            Offset finalPos = animated == Offset.zero ? base : animated;
                            Color tokenColor = index == 0 ? Colors.green : Colors.red;

                            return Positioned(
                              left: finalPos.dx - tokenSize / 2 - xOffset,
                              top: yOffset + finalPos.dy - tokenSize / 2,
                              child: Transform.rotate(
                                angle: rotation,
                                child: Icon(
                                  Icons.location_on,
                                  color: tokenColor,
                                  size: tokenSize * 1.2,
                                ),
                              ),
                            );
                          },
                        );
                      }),
                    ],
                  );
                },
              ),
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
