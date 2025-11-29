import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:snadders/game/play_with_friends.dart';
import '../services/iap_services.dart';
import '../widgets/buttons/exit_button.dart';

class FriendsMatchPage extends StatefulWidget {
  final IAPService iapService;
  final String gameId;
  final bool isPlayerOne;
  final String username;
  final String profileImage;

  const FriendsMatchPage({
    super.key,
    required this.iapService,
    required this.gameId,
    required this.isPlayerOne,
    required this.username,
    required this.profileImage,
  });

  @override
  FriendsMatchPageState createState() => FriendsMatchPageState();
}

class FriendsMatchPageState extends State<FriendsMatchPage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late Timer _timer;
  late int _coins;
  int _seconds = 120;
  late AnimationController _gradientController;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late StreamSubscription _roomSub;
  bool _opponentFound = false;
  Map<String, dynamic>? _opponentData;

  @override
  void initState() {
    super.initState();
    _coins = widget.iapService.coinsNotifier.value;
    WidgetsBinding.instance.addObserver(this);
    _gradientController =
    AnimationController(vsync: this, duration: const Duration(seconds: 3))
      ..repeat(reverse: true);
    _startTimer();
    _listenForOpponent();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_seconds > 0) {
        setState(() => _seconds--);
      } else {
        _timer.cancel();
        setState(() {
          if (!_opponentFound) {
            _opponentData = null;
          }
        });
      }
    });
  }

  void _listenForOpponent() {
    setState(() {
      _opponentFound = false;
      _opponentData = null;
    });

    _roomSub = _firestore
        .collection('rooms')
        .doc(widget.gameId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data();

        if (data != null) {
          final playerKey = widget.isPlayerOne ? 'player2' : 'player1';
          final opponent = data[playerKey];
          if (opponent != null && opponent['username'] != '') {
            setState(() {
              _opponentFound = true;
              _opponentData = opponent;
            });
            if (_opponentFound) {
              // update status to playing
              _firestore.collection('rooms').doc(widget.gameId).update({
                'status': 'playing',
              });
              _timer.cancel();
              _roomSub.cancel();
              setState(() {
                // _coins = _coins - 100;
                _coins = _coins;
              });
              widget.iapService.coinsNotifier.value = _coins;

              if (mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                      PlayWithFriends(
                        gameId: widget.gameId,
                        allAdsRemoved: widget.iapService.allAdsRemovedNotifier.value,
                        data: data,
                        myPlayerIndex: widget.isPlayerOne ? 0 : 1,
                      ),
                  )
                );
              }
            }
          }
        }
      }
    });
  }

  void _leavePage() async {
    await _firestore.collection('rooms').doc(widget.gameId).delete();
  }

  @override
  void dispose() {
    _roomSub.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _timer.cancel();
    _gradientController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.inactive) {
      _timer.cancel();
    } else if (state == AppLifecycleState.resumed) {
      _startTimer();
    }
  }

  String _formatTime(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFF151A1F).withOpacity(0.6),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Card(
                child: Container(
                  width: width * 0.9,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    gradient: LinearGradient(
                      colors: [
                        Colors.greenAccent,
                        Colors.purpleAccent.shade100,
                        Colors.blueAccent,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purpleAccent.withOpacity(0.3),
                        blurRadius: 30,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Game Logo
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Image.asset(
                              'assets/logo/foreground.png',
                              width: 200,
                              height: 200,
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.purpleAccent.withOpacity(0.8),
                                    Colors.blueAccent.withOpacity(0.8),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Text(
                                'SNAKES AND LADDERS',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Real Time Label
                        Container(
                          padding:
                          const EdgeInsets.symmetric(vertical: 6, horizontal: 14),
                          decoration: BoxDecoration(
                            color: Colors.yellowAccent.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: const Text(
                            'REAL TIME MULTIPLAYER',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.purple,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        // A container box showing the game id
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Text('Game ID: ${gameDoc.id}', style: const TextStyle(color: Colors.white70)),
                                  Text(
                                    'Game ID: ${widget.gameId}',
                                    style: const TextStyle(
                                      color: Colors.black87,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  IconButton(
                                    icon: const Icon(Icons.copy, color: Colors.purple),
                                    onPressed: (){
                                      Clipboard.setData(ClipboardData(text: widget.gameId));
                                      ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Game ID copied to clipboard.'),
                                            behavior: SnackBarBehavior.floating,
                                          ));
                                    },
                                  )
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 200,
                                    height: 50,
                                    child: Text(
                                      'Share this Game ID with your friend to join',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.share, color: Colors.purple),
                                    onPressed: () {
                                      Share.share('Join my game with this Game ID: ${widget.gameId}');
                                    },
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 10),

                        Text(
                          'Entry Amount: 100',
                          style: TextStyle(
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Players Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildPlayer(widget.username, widget.profileImage, Colors.red),
                            AnimatedBuilder(
                              animation: _gradientController,
                              builder: (context, _) {
                                return ShaderMask(
                                  shaderCallback: (bounds) {
                                    return LinearGradient(
                                      colors: [
                                        Colors.redAccent,
                                        Colors.orangeAccent,
                                        Colors.blueAccent,
                                      ],
                                      stops: [
                                        _gradientController.value * 0.5,
                                        _gradientController.value,
                                        (_gradientController.value + 0.5) % 1,
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ).createShader(bounds);
                                  },
                                  child: const Text(
                                    'VS',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 28,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                );
                              },
                            ),
                            _opponentFound && _opponentData != null
                                ? _buildPlayer(
                                _opponentData!['username'],
                                _opponentData!['profileImage'],
                                Colors.blue)
                                : _buildPlayer(
                                '???',
                                'assets/images/persons/person_in_question.png',
                                Colors.grey),
                          ],
                        ),

                        const SizedBox(height: 10),

                        // Timer
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.purpleAccent.shade700,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.purpleAccent.withOpacity(0.4),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.timer, color: Colors.white),
                              const SizedBox(width: 8),
                              Text(
                                _formatTime(_seconds),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 25),

                        // Searching bar
                        _opponentFound
                            ? Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.greenAccent.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Opponent found! Start the game.',
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                        )
                            : Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 22, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: _seconds > 0 ? _buildSearchingIndicator() : _buildNoPlayersFound(),
                        ),
                        const SizedBox(height: 15),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            ExitButton(
              onPressed: () {
                _leavePage();
                Navigator.pop(context);
                Navigator.pop(context);
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayer(String name, String imagePath, Color color) {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [color.withOpacity(0.8), color.withOpacity(0.4)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.5),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(imagePath, fit: BoxFit.cover),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          constraints: const BoxConstraints(maxWidth: 100),
          decoration: BoxDecoration(
            color: Colors.greenAccent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white30),
          ),
          child: Text(
            name,
            style: const TextStyle(
              color: Colors.purple,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchingIndicator() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
          ),
        ),
        const SizedBox(width: 10),
        const Text(
          'Waiting for player...',
          style: TextStyle(
            color: Colors.purple,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildNoPlayersFound() {
    return const Text(
      'Oops! Time over.',
      style: TextStyle(
        color: Colors.red,
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    );
  }
}
