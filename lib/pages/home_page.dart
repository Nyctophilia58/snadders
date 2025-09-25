import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snadders/services/shared_prefs_service.dart';
import 'package:snadders/widgets/profile/profile_avatar.dart';
import '../game/pass_N_play.dart';
import '../game/play_VS_computer.dart';
import '../game/player_selection.dart';
import '../services/ad_interstitial_service.dart';
import '../services/ad_reward_service.dart';
import '../pages/settings_page.dart';
import '../pages/statistics_page.dart';
import '../widgets/wheel/wheel.dart';

class HomePage extends StatefulWidget {
  final String username;
  final bool isGuest;

  const HomePage({super.key, required this.username, required this.isGuest});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  int coins = 0;
  int diamonds = 0;
  final SharedPrefsService _sharedPrefsService = SharedPrefsService();
  Timer? cooldownTimer;
  int remainingCooldown = 0;
  bool canSpin = true;
  String profileImagePath = SharedPrefsService.defaultProfileImage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadCoins();
    _loadDiamonds();
    _checkSpin();
    _loadProfileImage();
    AdRewardService.loadRewardedAd();
    AdInterstitialService.loadInterstitialAd();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    cooldownTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadCoins();
      _loadDiamonds();
      _checkSpin();
    }
  }

  Future<void> _loadCoins() async {
    final loadedCoins = await _sharedPrefsService.loadCoins();
    setState(() {
      coins = loadedCoins;
    });
  }

  Future<void> _loadDiamonds() async {
    final loadedDiamonds = await _sharedPrefsService.loadDiamonds();
    setState(() {
      diamonds = loadedDiamonds;
    });
  }

  Future<void> _checkSpin() async {
    canSpin = await _sharedPrefsService.canSpin();
    remainingCooldown = await _sharedPrefsService.getRemainingCooldown();
    if (!canSpin) {
      _startCooldownTimer();
    }
    setState(() {});
  }

  Future<void> _loadProfileImage() async {
    final image = await _sharedPrefsService.loadProfileImage();
    setState(() {
      profileImagePath = image;
    });
  }

  Future<String> _getProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('profileImage') ?? 'assets/images/persons/person.jpg';
  }

  void _startCooldownTimer() {
    cooldownTimer?.cancel();
    cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      remainingCooldown = await _sharedPrefsService.getRemainingCooldown();
      if (remainingCooldown == 0) {
        canSpin = true;
        timer.cancel();
      }
      setState(() {});
    });
  }

  void _onSpinCompleted() {
    _loadCoins();
    _loadDiamonds();
    _sharedPrefsService
        .saveLastSpinTimestamp(DateTime.now().millisecondsSinceEpoch);
    _checkSpin();
  }

  String _formatCooldown(int millis) {
    final seconds = millis ~/ 1000;
    final minutes = seconds ~/ 60;
    return minutes.toString().padLeft(2, '0');
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.greenAccent, Colors.blueAccent],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.deepPurple, Colors.purpleAccent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black26,
                            blurRadius: 6,
                            offset: Offset(0, 3)),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            FutureBuilder<String>(
                              future: _getProfileImage(),
                              builder: (context, snapshot) {
                                return ProfileAvatar(
                                  imagePath: profileImagePath,
                                  size: 40,
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => Dialog(
                                        backgroundColor: Colors.transparent,
                                        insetPadding: const EdgeInsets.all(16),
                                        child: StatisticsPage(username: widget.username, isGuest: widget.isGuest, imagePath: profileImagePath),
                                      ),
                                    ).then((_) {
                                      _loadProfileImage();
                                    });
                                  }
                                );
                              }
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.username,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Row(
                                  children: [
                                    const Icon(Icons.monetization_on,
                                        color: Colors.yellow, size: 18),
                                    const SizedBox(width: 4),
                                    Text(
                                      coins.toString(),
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(Icons.diamond,
                                color: Colors.lightBlueAccent),
                            const SizedBox(width: 4),
                            Text(
                              diamonds.toString(),
                              style: const TextStyle(color: Colors.white),
                            ),
                            const SizedBox(width: 12),
                            IconButton(
                              icon: const Icon(Icons.store, color: Colors.white),
                              onPressed: () {},
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  Expanded(
                    child: Center(
                      child: Column(
                        children: [
                          if (!widget.isGuest)
                            const SizedBox(height: 60)
                          else
                            const SizedBox(height: 100),
                          Image.asset(
                            'assets/logo/foreground.png',
                            width: 150,
                            height: 150,
                          ),
                          const SizedBox(height: 20),
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 20,
                            runSpacing: 20,
                            children: [
                              if (!widget.isGuest)
                                _buildButton(
                                  'PLAY ONLINE',
                                  Icons.people,
                                      () {},
                                ),
                              if (!widget.isGuest)
                                _buildButton(
                                  'PLAY WITH FRIENDS',
                                  Icons.people,
                                      () {},
                                ),
                              _buildButton(
                                'VS COMPUTER',
                                Icons.smart_toy,
                                    () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PlayVsComputer(
                                          username: widget.username),
                                    ),
                                  );
                                },
                              ),
                              _buildButton(
                                'PASS N PLAY',
                                Icons.group,
                                    () async {
                                  final selectedPlayers =
                                  await showPlayerSelectionDialog(context);
                                  if (selectedPlayers != null) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => PassNPlay(
                                            selectedPlayers: selectedPlayers),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 30),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildSmallButton(
                                  'Scores', Icons.emoji_events, () {}),
                              const SizedBox(width: 10),
                              _buildSmallButton('Settings', Icons.settings, () {
                                showDialog(
                                  context: context,
                                  builder: (context) => const Dialog(
                                    backgroundColor: Colors.transparent,
                                    insetPadding: EdgeInsets.all(16),
                                    child: SettingsPage(),
                                  ),
                                );
                              }),
                              const SizedBox(width: 10),
                              _buildSmallButton(
                                'Remove ADs',
                                Icons.video_library,
                                () {},
                                showFire: true
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // free coins bottom left
            Positioned(
              bottom: 20,
              left: 20,
              child: GestureDetector(
                child: Column(
                  children: [
                    Lottie.asset(
                      'assets/animations/free_coins.json',
                      repeat: true,
                      width: 50,
                      height: 50,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Free Coins',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            blurRadius: 10,
                            color: Colors.yellowAccent,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                onTap: () async {
                  bool adWatched = await AdRewardService.showRewardedAd();
                  if (adWatched) {
                    setState(() {
                      coins += 10;
                      _sharedPrefsService.saveCoins(coins);
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("You earned 10 coins!")),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("Ad not ready. Try again later.")),
                    );
                  }
                },
              ),
            ),
            // spin wheel bottom right
            Positioned(
              bottom: 20,
              right: 20,
              child: GestureDetector(
                onTap: () {
                  if (canSpin) {
                    showDialog(
                      context: context,
                      builder: (context) => Dialog(
                        backgroundColor: Colors.transparent,
                        insetPadding: const EdgeInsets.all(16),
                        child: Wheel(onSpinCompleted: _onSpinCompleted),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "Next spin available in ${_formatCooldown(remainingCooldown)} minutes",
                        ),
                      ),
                    );
                  }
                },
                child: Column(
                  children: [
                    Lottie.asset(
                      'assets/animations/spin_win.json',
                      repeat: true,
                      width: 60,
                      height: 60,
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(String text, IconData icon, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        backgroundColor: Colors.white,
        elevation: 6,
        shadowColor: Colors.deepPurple.withOpacity(0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.deepPurple, size: 38),
          const SizedBox(height: 8),
          Text(
            text,
            style: const TextStyle(
                color: Colors.deepPurple, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallButton(String text, IconData icon, VoidCallback onTap,
      {bool showFire = false}) {
    return SizedBox(
      width: 90,
      height: 70,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(8),
              backgroundColor: Colors.white,
              elevation: 4,
              shadowColor: Colors.deepPurple.withOpacity(0.3),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.deepPurple, size: 28),
                const SizedBox(height: 6),
                Text(
                  text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.deepPurple,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (showFire)
            Positioned(
              top: -10,
              right: -6,
              child: Lottie.asset(
                'assets/animations/fire.json',
                width: 30,
                height: 30,
                repeat: true,
              ),
            ),
        ],
      ),
    );
  }
}
