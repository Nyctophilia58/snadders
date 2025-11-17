import 'dart:async';
import 'package:flutter/material.dart';
import '../services/shared_prefs_service.dart';
import '../widgets/buttons/exit_button.dart';

class LobbyPage extends StatefulWidget {
  final String username;
  final int stakeCoins;
  final String imagePath;

  const LobbyPage({
    super.key,
    required this.username,
    required this.stakeCoins,
    required this.imagePath,
  });

  @override
  LobbyPageState createState() => LobbyPageState();
}

class LobbyPageState extends State<LobbyPage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late Timer _timer;
  int _seconds = 20;
  late AnimationController _gradientController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SharedPrefsService().setLobbyStatus(true);
    _gradientController =
    AnimationController(vsync: this, duration: const Duration(seconds: 3))
      ..repeat(reverse: true);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_seconds > 0) {
        setState(() => _seconds--);
      } else {
        _timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    SharedPrefsService().setLobbyStatus(false);
    _timer.cancel();
    _gradientController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // App is being backgrounded or closed
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.inactive) {
      SharedPrefsService().setLobbyStatus(false);
    }
    // App returns to foreground
    else if (state == AppLifecycleState.resumed) {
      SharedPrefsService().setLobbyStatus(true);
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
                    padding: const EdgeInsets.all(20),
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
                
                        Text(
                          'Entry Amount: ${widget.stakeCoins}',
                          style: TextStyle(
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 50),
                
                        // Players Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildPlayer(widget.username, widget.imagePath, Colors.red),
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
                            _buildPlayer('???', 'assets/images/persons/person_in_question.png', Colors.blue),
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
                        Container(
                          padding:
                          const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.green.shade700),
                                ),
                              ),
                              SizedBox(width: 10),
                              Text(
                                'Searching for player...',
                                style: TextStyle(
                                  color: Colors.yellow.shade500,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
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
                Navigator.pop(context);
              }
            ),
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
          constraints: const BoxConstraints(
            maxWidth: 100, // limit width to avoid overflow
          ),
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
}
