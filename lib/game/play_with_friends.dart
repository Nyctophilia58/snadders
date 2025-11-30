import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import 'package:snadders/game/controllers/game_controller.dart';
import 'package:snadders/services/ad_services/ad_banner_service.dart';
import '../services/ad_services/ad_interstitial_service.dart';
import '../services/shared_prefs_service.dart';
import '../widgets/audio_manager.dart';
import '../widgets/buttons/exit_button.dart';
import 'data/ladders_data.dart';
import 'data/snakes_data.dart';
import 'game_utils_online.dart';

class PlayWithFriends extends StatefulWidget {
  final String gameId;
  final bool allAdsRemoved;
  final Map<String, dynamic> data;
  final int myPlayerIndex;

  const PlayWithFriends({
    super.key,
    required this.gameId,
    required this.allAdsRemoved,
    required this.data,
    required this.myPlayerIndex
  });

  @override
  State<PlayWithFriends> createState() => _PlayWithFriendsState();
}

class _PlayWithFriendsState extends State<PlayWithFriends> with TickerProviderStateMixin {
  late GameController controller;
  late AnimationController _winnerAnimationController;
  late Animation<double> _winnerAnimation;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final SharedPrefsService _prefsService = SharedPrefsService();

  final List<Color> playerColors = [Colors.green, Colors.red];
  final List<String> colorNames = ['green', 'red'];
  late List<String> playerNames = [widget.data['player1']['username'], widget.data['player2']['username']];
  late List<String> playerImages = [widget.data['player1']['profileImage'], widget.data['player2']['profileImage']];
  late List<String> playerUids = [widget.data['player1']['uid'], widget.data['player2']['uid']];

  // Animation controllers for each token
  late List<AnimationController> _tokenControllers;
  late List<Animation<Offset>> _tokenAnimations;
  late List<Animation<double>> _tokenRotations;
  late List<AnimationController> _tokenIdleControllers;

  late StreamSubscription _gameSub;
  DateTime? _lastMoveTimestamp;
  late int boardNumber = widget.data['boardNumber'];
  bool _isAnimating = false;
  late int myPlayerIndex = widget.myPlayerIndex;
  bool _isExiting = false;

  // Dice sync state
  late List<String?> _diceRollTriggers;
  late List<int?> _forcedDiceValues;

  @override
  void initState() {
    super.initState();
    controller = GameController(
      totalPlayers: 2,
      boardNumber: boardNumber,
      playerNames: playerNames,
    );
    // Initialize from passed data
    controller.playerPositions = List<int>.from(widget.data['playerPositions'] ?? [1, 1]);
    controller.currentPlayerIndex = widget.data['currentPlayerIndex'] ?? 0;

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

    // Dice sync init
    _diceRollTriggers = List<String?>.filled(2, null);
    _forcedDiceValues = List<int?>.filled(2, null);

    AdBannerService.loadBannerAd();

    // Listen for real-time game updates
    _gameSub = _firestore
        .collection('rooms')
        .doc(widget.gameId)
        .snapshots()
        .listen((snapshot) {
      if (mounted) {
        if (snapshot.exists) {
          final data = snapshot.data()!;
          // Sync winner
          final String? newWinner = data['winner'];
          if (newWinner != null && controller.winner == null) {
            controller.winner = newWinner;
            _winnerAnimationController.forward();
            GameUtilsOnline.showWinnerDialog(
              context: context,
              winnerName: newWinner,
              winnerUid: playerUids[playerNames.indexOf(newWinner)],
              service: _prefsService,
              onPlayAgain: _resetGame,
              onExit: _exitGame,
              allAdsRemoved: widget.allAdsRemoved,
            );
          }
          // Always sync current player
          final int newCurrentIndex = data['currentPlayerIndex'] ?? 0;
          controller.currentPlayerIndex = newCurrentIndex;
          // Handle moves
          final Map<String, dynamic>? lastMove = data['lastMove'];
          if (lastMove != null && lastMove['timestamp'] != null) {
            final String tsStr = lastMove['timestamp'];
            final DateTime ts = DateTime.parse(tsStr);
            final bool isNewMove = _lastMoveTimestamp == null || ts.isAfter(_lastMoveTimestamp!);
            if (isNewMove) {
              _lastMoveTimestamp = ts;
              final int mover = lastMove['player'];
              if (mover != myPlayerIndex) {
                // Opponent move: sync dice + delay token anim
                final int from = lastMove['from'];
                controller.playerPositions[mover] = from;
                _forcedDiceValues[mover] = lastMove['dice'];
                _diceRollTriggers[mover] = DateTime.now().millisecondsSinceEpoch.toString();
                setState(() {});  // Triggers dice roll anim + position reset
                // Delay token anim to sync with dice duration
                Future.delayed(const Duration(milliseconds: 1000), () {
                  if (mounted) {
                    _animateOpponentMove(lastMove);
                  }
                });
              } else {
                // Own move: already handled locally
              }
            }
          } else {
            // No lastMove: safe to sync positions (initial load, reset, or turn switch without move)
            if (!_isAnimating) {
              controller.playerPositions = List<int>.from(data['playerPositions'] ?? [1, 1]);
            }
          }
          setState(() {});
        } else if (!_isExiting) {
          _showGameEndedDialog();
        }
      }
    });
  }

  void _showGameEndedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Game Ended"),
        content: const Text("Your opponent has left the game."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _exitGame();
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  Future<void> _exitGame() async {
    if (_isExiting) return;
    _isExiting = true;
    await _firestore.collection('rooms').doc(widget.gameId).delete();
    if (mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  void dispose() {
    _gameSub.cancel();
    for (var c in _tokenControllers) {
      c.dispose();
    }
    for (var c in _tokenIdleControllers) {
      c.dispose();
    }
    _winnerAnimationController.dispose();
    super.dispose();
  }

  Future<void> _animateOpponentMove(Map<String, dynamic> move) async {
    if (_isAnimating) return;
    _isAnimating = true;
    final int index = move['player'];
    final int from = move['from'];
    final int intermediate = move['intermediate'];
    final int to = move['to'];

    // Position already set to from in listener

    // Animate hops to intermediate
    for (int pos = from + 1; pos <= intermediate; pos++) {
      await _animateTokenHop(index, pos);
    }

    // Animate snake or ladder if applicable
    if (to != intermediate) {
      if (to > intermediate) {
        await _animateLadder(index, intermediate, to);
      } else if (to < intermediate) {
        await _animateSnake(index, intermediate, to);
      }
    }

    // Ensure final position
    controller.playerPositions[index] = to;
    _isAnimating = false;
    setState(() {});
  }

  void _handleDiceRoll(int playerIndex, int dice) async {
    if (_isAnimating ||
        controller.winner != null ||
        controller.currentPlayerIndex != playerIndex ||
        playerIndex != myPlayerIndex) {
      return;
    }

    _isAnimating = true;
    int oldPosition = controller.playerPositions[playerIndex];
    int intermediate = oldPosition + dice;

    if (intermediate > 100) {
      final Map<String, dynamic> updates = {'currentPlayerIndex': (playerIndex + 1) % 2};
      await _firestore
          .collection('rooms')
          .doc(widget.gameId)
          .update(updates);
      controller.currentPlayerIndex = (playerIndex + 1) % 2;
      _isAnimating = false;
      setState(() {});
      return;
    }

    // Calculate final position (unchanged)
    int finalPos = intermediate;
    final ladders = laddersList[controller.boardNumber - 1];
    final snakes = snakesList[controller.boardNumber - 1];
    if (ladders.containsKey(intermediate)) {
      finalPos = ladders[intermediate]!;
    } else if (snakes.containsKey(intermediate)) {
      finalPos = snakes[intermediate]!;
    }

    // Update Firestore IMMEDIATELY for positions and lastMove (for remote sync/animation trigger)
    // But DELAY currentPlayerIndex/winner until after local anim
    Map<String, dynamic> initialUpdates = {
      'playerPositions.$playerIndex': finalPos,  // Remote sees final pos immediately
      'lastMove': {
        'player': playerIndex,
        'dice': dice,
        'from': oldPosition,
        'intermediate': intermediate,
        'to': finalPos,
        'timestamp': DateTime.now().toIso8601String(),
      },
    };
    await _firestore
        .collection('rooms')
        .doc(widget.gameId)
        .update(initialUpdates);

    // Animate locally (unchanged)
    for (int pos = oldPosition + 1; pos <= intermediate; pos++) {
      await _animateTokenHop(playerIndex, pos);
    }
    if (finalPos != intermediate) {
      if (finalPos > intermediate) {
        await _animateLadder(playerIndex, intermediate, finalPos);
      } else {
        await _animateSnake(playerIndex, intermediate, finalPos);
      }
    }

    // NOW switch turn/winner AFTER animation (local + Firestore)
    Map<String, dynamic> turnUpdates = {};
    if (finalPos == 100) {
      turnUpdates['winner'] = playerNames[playerIndex];
      String winnerUid = playerUids[playerIndex];
      controller.winner = playerNames[playerIndex];
      _winnerAnimationController.forward();
      GameUtilsOnline.showWinnerDialog(
        context: context,
        winnerName: playerNames[playerIndex],
        winnerUid: winnerUid,
        service: _prefsService,
        onPlayAgain: _resetGame,
        onExit: _exitGame,
        allAdsRemoved: widget.allAdsRemoved,
      );
    } else {
      int nextIndex = (playerIndex + 1) % 2;
      turnUpdates['currentPlayerIndex'] = nextIndex;
      controller.currentPlayerIndex = nextIndex;
    }
    if (turnUpdates.isNotEmpty) {
      await _firestore
          .collection('rooms')
          .doc(widget.gameId)
          .update(turnUpdates);
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

  void _resetGame() async {
    // Reset local state
    controller.reset();
    _winnerAnimationController.reset();
    _isAnimating = false;
    _lastMoveTimestamp = null;

    // Reset dice sync state
    _diceRollTriggers = List<String?>.filled(2, null);
    _forcedDiceValues = List<int?>.filled(2, null);

    // Reset token animations
    for (int i = 0; i < _tokenControllers.length; i++) {
      _tokenControllers[i].reset();
      _tokenAnimations[i] = AlwaysStoppedAnimation(Offset.zero);
      _tokenRotations[i] = AlwaysStoppedAnimation(0.0);
      _tokenIdleControllers[i].forward(); // Restart idle bob
    }

    // Reset Firestore game state
    await _firestore.collection('rooms').doc(widget.gameId).update({
      'playerPositions': [1, 1],
      'currentPlayerIndex': 0,
      'winner': null,
      'lastMove': null,
    });

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
                      label: playerNames[0],
                      color: Colors.green,
                      currentPlayerIndex: controller.currentPlayerIndex,
                      autoRollDice: false,
                      onRolled: _handleDiceRoll,
                      profileImage: playerImages[0],
                      myPlayerIndex: myPlayerIndex,
                      diceRollTrigger: _diceRollTriggers[0],
                      forcedDiceValue: _forcedDiceValues[0],
                    ),
                    GameUtilsOnline.buildPlayerInfo(
                      playerIndex: 1,
                      label: playerNames[1],
                      color: Colors.red,
                      currentPlayerIndex: controller.currentPlayerIndex,
                      autoRollDice: false,
                      onRolled: _handleDiceRoll,
                      profileImage: playerImages[1],
                      myPlayerIndex: myPlayerIndex,
                      diceRollTrigger: _diceRollTriggers[1],
                      forcedDiceValue: _forcedDiceValues[1],
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
                                _exitGame();
                                if (!widget.allAdsRemoved) {
                                  AdInterstitialService.showInterstitialAd();
                                }
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