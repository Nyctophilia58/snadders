import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import 'package:snadders/game/controllers/game_controller.dart';
import 'package:snadders/services/ad_services/ad_banner_service.dart';
import '../widgets/audio_manager.dart';
import '../widgets/buttons/exit_button.dart';
import 'data/ladders_data.dart';
import 'data/snakes_data.dart';
import 'game_utils_online.dart';

class PlayWithFriends extends StatefulWidget {
  final String gameId;
  final bool allAdsRemoved ;
  final Map<String, dynamic> data;

  const PlayWithFriends({super.key, required this.gameId, required this.allAdsRemoved, required this.data});

  @override
  State<PlayWithFriends> createState() => _PlayWithFriendsState();
}

class _PlayWithFriendsState extends State<PlayWithFriends> with TickerProviderStateMixin {
  late GameController controller;
  late AnimationController _winnerAnimationController;
  late Animation<double> _winnerAnimation;

  final List<Color> playerColors = [Colors.green, Colors.red];
  final List<String> colorNames = ['green', 'red'];
  late List<String> playerNames = [widget.data['player1']['username'], widget.data['player2']['username']];
  late List<String> playerImages = [widget.data['player1']['profileImage'], widget.data['player2']['profileImage']];

  // Animation controllers for each token
  late List<AnimationController> _tokenControllers;
  late List<Animation<Offset>> _tokenAnimations;
  late List<Animation<double>> _tokenRotations;
  late List<AnimationController> _tokenIdleControllers;

  late int boardNumber = widget.data['boardNumber'];
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    controller = GameController(
      totalPlayers: 2,
      boardNumber: boardNumber,
      playerNames: playerNames,
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

    _tokenIdleControllers = List.generate(
      2,
          (_) => AnimationController(vsync: this, duration: const Duration(seconds: 2)),
    );
    for (var ctrl in _tokenIdleControllers) {
      ctrl.repeat(reverse: true);
    }

    AdBannerService.loadBannerAd();
  }

  @override
  void dispose() {
    for (var c in _tokenControllers) {
      c.dispose();
    }
    for (var c in _tokenIdleControllers) {
      c.dispose();
    }
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
      GameUtilsOnline.showWinnerDialog(
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
    await AudioManager.instance.playSFX('audios/jump-6293.mp3');
    final animCtrl = _tokenControllers[index];
    final Offset startOffset = _getCellOffset(controller.playerPositions[index]);
    final Offset endOffset = _getCellOffset(targetPosition);
    final double hopHeight = 20.0;

    void listener() {
      final double t = animCtrl.value;
      final double verticalOffset = 4 * hopHeight * t * (t - 1);
      final Offset delta = Offset(
        (endOffset.dx - startOffset.dx) * t,
        (endOffset.dy - startOffset.dy) * t + verticalOffset,
      );
      _tokenAnimations[index] = AlwaysStoppedAnimation(delta);
      setState(() {});
    }

    animCtrl.addListener(listener);
    animCtrl.reset();
    animCtrl.duration = const Duration(milliseconds: 300);
    await animCtrl.forward();
    animCtrl.removeListener(listener);
    _tokenAnimations[index] = AlwaysStoppedAnimation(Offset.zero);
    controller.playerPositions[index] = targetPosition;
    setState(() {});
  }

  Future<void> _animateLadder(int index, int start, int end) async {
    await AudioManager.instance.playSFX('audios/climb-5169.mp3');
    final animCtrl = _tokenControllers[index];
    final Offset startOffset = _getCellOffset(start);
    final Offset endOffset = _getCellOffset(end);
    final double hopHeight = 25.0;

    void listener() {
      final double t = animCtrl.value;
      final double verticalOffset = 4 * hopHeight * t * (t - 1); // Fixed: arc upwards like hop
      final Offset delta = Offset(
        (endOffset.dx - startOffset.dx) * t,
        (endOffset.dy - startOffset.dy) * t + verticalOffset,
      );
      _tokenAnimations[index] = AlwaysStoppedAnimation(delta);
      setState(() {});
    }

    animCtrl.addListener(listener);
    animCtrl.reset();
    animCtrl.duration = const Duration(milliseconds: 700);
    await animCtrl.forward();
    animCtrl.removeListener(listener);
    _tokenAnimations[index] = AlwaysStoppedAnimation(Offset.zero);
    controller.playerPositions[index] = end;
    setState(() {});
  }

  Future<void> _animateSnake(int index, int start, int end, {int maxSpins = 6}) async {
    await AudioManager.instance.playSFX('audios/hiss-3724.mp3');
    final animCtrl = _tokenControllers[index];
    final rotationCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    final Offset startOffset = _getCellOffset(start);
    final Offset endOffset = _getCellOffset(end);
    final double hopHeight = 10.0;

    int distance = (start - end).abs();
    int spins = ((distance / 10) * maxSpins).clamp(1, maxSpins).toInt();

    void positionListener() {
      final double t = animCtrl.value;
      final double verticalOffset = -4 * hopHeight * t * (t - 1);
      final Offset delta = Offset(
        (endOffset.dx - startOffset.dx) * t,
        (endOffset.dy - startOffset.dy) * t + verticalOffset,
      );
      _tokenAnimations[index] = AlwaysStoppedAnimation(delta);
      setState(() {});
    }

    animCtrl.addListener(positionListener);

    _tokenRotations[index] = Tween<double>(begin: 0, end: spins * 2 * pi).animate(
      CurvedAnimation(parent: rotationCtrl, curve: Curves.linear),
    );

    animCtrl.reset();
    rotationCtrl.reset();
    animCtrl.duration = const Duration(milliseconds: 900);
    rotationCtrl.duration = const Duration(milliseconds: 900);

    await Future.wait([animCtrl.forward(), rotationCtrl.forward()]);
    animCtrl.removeListener(positionListener);
    _tokenAnimations[index] = AlwaysStoppedAnimation(Offset.zero);
    _tokenRotations[index] = AlwaysStoppedAnimation(0.0);
    rotationCtrl.dispose();
    controller.playerPositions[index] = end;
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

    return GameUtilsOnline.getPositionOffset(position, cellWidth, cellHeight, boardPadding);
  }

  void _resetGame() {
    // Reset game controller
    controller.reset();
    _winnerAnimationController.reset();
    _isAnimating = false;

    // Reset token animations
    for (int i = 0; i < _tokenControllers.length; i++) {
      _tokenControllers[i].reset();
      _tokenAnimations[i] = AlwaysStoppedAnimation(Offset.zero);
      _tokenRotations[i] = AlwaysStoppedAnimation(0.0);
      _tokenIdleControllers[i].forward(); // Restart idle bob
    }

    setState(() {});
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
                  double tokenSize = min(cellWidth, cellHeight) * 0.9; // Increased base size

                  // Compute player grouping by position for clustering
                  Map<int, List<int>> positionToPlayers = {};
                  for (int i = 0; i < 2; i++) {
                    int pos = controller.playerPositions[i];
                    positionToPlayers.putIfAbsent(pos, () => <int>[]).add(i);
                  }
                  for (var players in positionToPlayers.values) {
                    players.sort();
                  }

                  return Stack(
                    children: [
                      SvgPicture.asset(
                        'assets/images/boards/$boardNumber.svg',
                        width: containerWidth,
                        height: containerHeight,
                        fit: BoxFit.contain,
                      ),
                      ...List.generate(2, (index) {
                        return AnimatedBuilder(
                          animation: Listenable.merge([
                            _tokenControllers[index],
                            _tokenRotations[index],
                            _tokenIdleControllers[index],
                          ]),
                          builder: (context, child) {
                            int pos = controller.playerPositions[index];
                            List<int> playersAtPos = positionToPlayers[pos]!;
                            int playerCount = playersAtPos.length;
                            int myIndexInGroup = playersAtPos.indexOf(index);

                            Offset base = _getCellOffset(pos);
                            Offset withinCellOffset = Offset.zero;
                            double offsetAmount = min(cellWidth, cellHeight) * 0.35;

                            double adjustedTokenSize = tokenSize;
                            if (playerCount > 1) {
                              adjustedTokenSize = tokenSize * (0.8 / sqrt(playerCount));
                            }

                            if (playerCount > 1) {
                              List<Offset> clusterPositions = [
                                const Offset(-0.5, -0.5),
                                const Offset(0.5, -0.5),
                                const Offset(0.5, 0.5),
                                const Offset(-0.5, 0.5),
                              ];
                              if (myIndexInGroup < clusterPositions.length) {
                                withinCellOffset = clusterPositions[myIndexInGroup] * offsetAmount;
                              } else {
                                // For >4 (unlikely), stack further
                                withinCellOffset = Offset(0, (myIndexInGroup - 3) * offsetAmount * 2);
                              }
                            }

                            Offset animatedDelta = _tokenAnimations[index].value;
                            double rotation = _tokenRotations[index].value;
                            double idleScale = 0.95 + (_tokenIdleControllers[index].value * 0.1); // Subtle bob scale for 3D feel
                            Offset finalPos = base + withinCellOffset + animatedDelta;

                            String animationPath = 'assets/animations/tokens/${colorNames[index]}_token.json';

                            return Positioned(
                              left: finalPos.dx - adjustedTokenSize / 2 - xOffset,
                              top: yOffset + finalPos.dy - adjustedTokenSize / 2,
                              child: Transform.scale(
                                scale: idleScale,
                                child: Transform.rotate(
                                  angle: rotation,
                                  child: Lottie.asset(
                                    animationPath,
                                    width: adjustedTokenSize,
                                    height: adjustedTokenSize,
                                    repeat: true,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(
                                        Icons.location_on,
                                        color: playerColors[index],
                                        size: adjustedTokenSize,
                                      );
                                    },
                                  ),
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
                    GameUtilsOnline.buildPlayerInfo(
                      playerIndex: 0,
                      label: widget.data['player1']['username'],
                      color: Colors.green,
                      currentPlayerIndex: controller.currentPlayerIndex,
                      autoRollDice: false,
                      onRolled: _handleDiceRoll,
                      profileImage: playerImages[0],
                    ),
                    GameUtilsOnline.buildPlayerInfo(
                      playerIndex: 1,
                      label: widget.data['player2']['username'],
                      color: Colors.red,
                      currentPlayerIndex: controller.currentPlayerIndex,
                      autoRollDice: true,
                      onRolled: _handleDiceRoll,
                      isComputer: true,
                      profileImage: playerImages[1],
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