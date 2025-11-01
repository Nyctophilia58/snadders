import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import 'package:snadders/game/controllers/game_controller.dart';
import '../services/ad_services/ad_banner_service.dart';
import '../widgets/exit_button.dart';
import 'data/ladders_data.dart';
import 'data/snakes_data.dart';
import 'game_utils.dart';

class PassNPlay extends StatefulWidget {
  final int selectedPlayers;
  final int boardIndex;
  final bool allAdsRemoved;

  const PassNPlay({super.key, required this.selectedPlayers, required this.boardIndex, required this.allAdsRemoved});

  @override
  State<PassNPlay> createState() => _PassNPlayState();
}

class _PassNPlayState extends State<PassNPlay> with TickerProviderStateMixin {
  late GameController controller;
  late AnimationController _winnerAnimationController;
  late Animation<double> _winnerAnimation;
  late final AudioPlayer _audioPlayer;

  final List<Color> playerColors = [Colors.green, Colors.red, Colors.yellow, Colors.blue];
  final List<String> colorNames = ['green', 'red', 'yellow', 'blue'];

  late List<AnimationController> _tokenControllers;
  late List<Animation<Offset>> _tokenAnimations;
  late List<Animation<double>> _tokenRotations;
  late List<AnimationController> _tokenIdleControllers;

  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
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

    _tokenControllers = List.generate(
      widget.selectedPlayers,
          (_) => AnimationController(vsync: this, duration: const Duration(milliseconds: 1000)),
    );
    _tokenAnimations = List.generate(widget.selectedPlayers, (_) => AlwaysStoppedAnimation(Offset.zero));
    _tokenRotations = List.generate(widget.selectedPlayers, (_) => AlwaysStoppedAnimation(0.0));

    // Idle animation controllers for subtle 3D bob
    _tokenIdleControllers = List.generate(
      widget.selectedPlayers,
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
    _audioPlayer.dispose();
    super.dispose();
  }

  void _handleDiceRoll(int playerIndex, int dice) async {
    if (_isAnimating || controller.winner != null || controller.currentPlayerIndex != playerIndex) return;

    _isAnimating = true;
    int oldPosition = controller.playerPositions[playerIndex];
    int newPosition = oldPosition + dice;

    if (newPosition > 100) {
      controller.currentPlayerIndex = (playerIndex + 1) % widget.selectedPlayers;
      _isAnimating = false;
      setState(() {});
      return;
    }

    // Animate each square
    for (int pos = oldPosition + 1; pos <= newPosition; pos++) {
      await _animateTokenHop(playerIndex, pos);
    }

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
      controller.currentPlayerIndex = (playerIndex + 1) % widget.selectedPlayers;
    }

    _isAnimating = false;
    setState(() {});
  }

  Future<void> _animateTokenHop(int index, int targetPosition) async {
    await _audioPlayer.play(AssetSource('audios/jump-6293.mp3'));
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
    await _audioPlayer.play(AssetSource('audios/climb-5169.mp3'));
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
    await _audioPlayer.play(AssetSource('audios/hiss-3724.mp3'));
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

    return GameUtils.getPositionOffset(position, cellWidth, cellHeight, boardPadding);
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

    // Trigger rebuild so tokens jump back to start
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
                  for (int i = 0; i < widget.selectedPlayers; i++) {
                    int pos = controller.playerPositions[i];
                    positionToPlayers.putIfAbsent(pos, () => <int>[]).add(i);
                  }
                  for (var players in positionToPlayers.values) {
                    players.sort(); // Consistent ordering by player index
                  }

                  return Stack(
                    children: [
                      SvgPicture.asset(
                        'assets/images/boards/${widget.boardIndex + 1}.svg',
                        width: containerWidth,
                        height: containerHeight,
                        fit: BoxFit.contain,
                      ),
                      ...List.generate(widget.selectedPlayers, (index) {
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
                            double offsetAmount = min(cellWidth, cellHeight) * 0.35; // Increased for more separation

                            double adjustedTokenSize = tokenSize;
                            if (playerCount > 1) {
                              adjustedTokenSize = tokenSize * (0.8 / sqrt(playerCount)); // Less aggressive scaling down
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

              // Player info widgets
              ..._buildPlayerInfoWidgets(),

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

  List<Widget> _buildPlayerInfoWidgets() {
    List<Widget> widgets = [];
    if (widget.selectedPlayers >= 1) {
      widgets.add(Positioned(
        bottom: 80,
        left: 20,
        child: GameUtils.buildPlayerInfo(
          playerIndex: 0,
          label: "Player 1",
          color: playerColors[0],
          currentPlayerIndex: controller.currentPlayerIndex,
          autoRollDice: false,
          onRolled: _handleDiceRoll,
        ),
      ));
    }
    if (widget.selectedPlayers >= 2) {
      widgets.add(Positioned(
        bottom: 80,
        right: 20,
        child: GameUtils.buildPlayerInfo(
          playerIndex: 1,
          label: "Player 2",
          color: playerColors[1],
          currentPlayerIndex: controller.currentPlayerIndex,
          autoRollDice: false,
          onRolled: _handleDiceRoll,
        ),
      ));
    }
    if (widget.selectedPlayers >= 3) {
      widgets.add(Positioned(
        top: 70,
        right: 20,
        child: GameUtils.buildPlayerInfo(
          playerIndex: 2,
          label: "Player 3",
          color: playerColors[2],
          currentPlayerIndex: controller.currentPlayerIndex,
          autoRollDice: false,
          onRolled: _handleDiceRoll,
        ),
      ));
    }
    if (widget.selectedPlayers >= 4) {
      widgets.add(Positioned(
        top: 70,
        left: 20,
        child: GameUtils.buildPlayerInfo(
          playerIndex: 3,
          label: "Player 4",
          color: playerColors[3],
          currentPlayerIndex: controller.currentPlayerIndex,
          autoRollDice: false,
          onRolled: _handleDiceRoll,
        ),
      ));
    }
    return widgets;
  }
}