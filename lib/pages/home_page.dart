import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:snadders/pages/coin_selection_page.dart';
import 'package:snadders/pages/page_controllers/home_page_controller.dart';
import '../game/board_selection.dart';
import '../pages/store_page.dart';
import '../services/iap_services.dart';
import '../widgets/profile/profile_avatar.dart';
import '../game/pass_N_play.dart';
import '../game/play_VS_computer.dart';
import '../game/player_selection.dart';
import '../pages/settings_page.dart';
import '../pages/statistics_page.dart';
import '../widgets/ad_removal_selection.dart';
import '../widgets/wheel/wheel.dart';
import 'lobby_page.dart';

class HomePage extends StatefulWidget {
  final IAPService iapService;
  final String username;
  final bool isGuest;

  const HomePage({
    super.key,
    required this.username,
    required this.isGuest,
    required this.iapService,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late HomePageController controller;

  @override
  void initState() {
    super.initState();
    controller = HomePageController();
    WidgetsBinding.instance.addObserver(this);
    controller.init(initialUsername: widget.username).then((_) => setState(() {}));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    controller.dispose();
    super.dispose();
  }

  Future<String> _getProfileImage() async {
    return controller.profileImagePath;
  }

  void _onSpinCompleted() async {
    await controller.onSpinCompleted();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final screenHeight = constraints.maxHeight;
          final bottomPadding = screenHeight * 0.02;
          final lottieSize = screenHeight < 700 ? 40.0 : 60.0;

          return Scaffold(
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
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
                                      imagePath: controller.profileImagePath,
                                      size: 40,
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => Dialog(
                                            backgroundColor: Colors.transparent,
                                            insetPadding: const EdgeInsets.all(16),
                                            child: StatisticsPage(
                                              username: controller.username,
                                              isGuest: widget.isGuest,
                                            ),
                                          ),
                                        ).then((_) async {
                                          await controller.loadProfileImage();
                                          await controller.loadUsername();
                                          setState(() {});
                                        });
                                      },
                                    );
                                  },
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      controller.username,
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
                                        ValueListenableBuilder<int>(
                                          valueListenable: widget.iapService.coinsNotifier,
                                          builder: (context, coins, _) {
                                            if (!mounted) return const SizedBox();
                                            return Text('$coins', style: const TextStyle(color: Colors.white));
                                          },
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
                                ValueListenableBuilder<int>(
                                  valueListenable: widget.iapService.diamondsNotifier,
                                  builder: (context, diamonds, _) {
                                    if (!mounted) return const SizedBox();
                                    return Text('$diamonds', style: const TextStyle(color: Colors.white));
                                  },
                                ),
                                const SizedBox(width: 12),
                                IconButton(
                                  icon: const Icon(Icons.store,
                                      color: Colors.white),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                        StorePage(initialTabIndex: 0, iapService: widget.iapService),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(vertical: 16),
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
                                  _buildButton(
                                    'PLAY ONLINE',
                                    Icons.people,
                                    () async {
                                      final selectedCoins = await showDialog<int>(
                                        context: context,
                                        barrierColor: Colors.black38,
                                        builder: (context) => CoinSelectionPage(
                                          coins: widget.iapService.coinsNotifier.value ?? 0,
                                          diamonds: widget.iapService.diamondsNotifier.value ?? 0,
                                        ),
                                      );
                                      if (selectedCoins != null) {
                                        showDialog(
                                          context: context,
                                          barrierColor: Colors.black38,
                                          builder: (context) => LobbyPage(
                                            username: controller.username,
                                            stakeCoins: selectedCoins,
                                            imagePath: controller.profileImagePath,
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                  _buildButton(
                                    'PLAY WITH FRIENDS',
                                    Icons.people,
                                    () {},
                                  ),
                                  _buildButton(
                                    'VS COMPUTER',
                                    Icons.smart_toy,
                                        () async {
                                      final selectedBoardIndex = await showDialog<int>(
                                        context: context,
                                        builder: (context) => BoardSelector(iapService: widget.iapService,),
                                      );

                                      if (selectedBoardIndex != null) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => PlayVsComputer(
                                              username: controller.username,
                                              boardIndex: selectedBoardIndex,
                                              allAdsRemoved: widget.iapService.allAdsRemovedNotifier.value,
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                  _buildButton(
                                    'PASS N PLAY',
                                    Icons.group,
                                        () async {
                                      final selectedBoardIndex = await showDialog<int>(
                                        context: context,
                                        builder: (context) => BoardSelector(iapService: widget.iapService,),
                                      );

                                      if (selectedBoardIndex != null) {
                                        final selectedPlayers = await showPlayerSelectionDialog(context);
                                        if (selectedPlayers != null) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => PassNPlay(
                                                selectedPlayers: selectedPlayers,
                                                boardIndex: selectedBoardIndex,
                                                allAdsRemoved: widget.iapService.allAdsRemovedNotifier.value,
                                              ),
                                            ),
                                          );
                                        }
                                      }
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 30),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildSmallButton('Scores', Icons.emoji_events, () {}),
                                  const SizedBox(width: 10),
                                  _buildSmallButton(
                                      'Settings', Icons.settings, () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => Dialog(
                                        backgroundColor: Colors.transparent,
                                        insetPadding: const EdgeInsets.all(16),
                                        child: SettingsPage(iapService: widget.iapService,),
                                      ),
                                    );
                                  }),
                                  const SizedBox(width: 10),
                                  ValueListenableBuilder<bool>(
                                    valueListenable: widget.iapService.allAdsRemovedNotifier,
                                    builder: (context, allRemoved, _) {
                                      return ValueListenableBuilder<bool>(
                                        valueListenable: widget.iapService.rewardedAdsRemovedNotifier,
                                        builder: (context, rewardedRemoved, _) {
                                          if (allRemoved && rewardedRemoved) return const SizedBox.shrink();

                                          return _buildSmallButton(
                                            'Remove ADs',
                                            Icons.video_library,
                                            () async {
                                              await showAdRemovalSelectionDialog(context, widget.iapService);
                                              setState(() {});
                                            },
                                            showFire: true,
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ],
                              ),
                              SizedBox(height: bottomPadding + 60),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // free coins bottom left
                Positioned(
                  bottom: bottomPadding,
                  left: 20,
                  child: GestureDetector(
                    child: Column(
                      children: [
                        Lottie.asset(
                          'assets/animations/free_coins.json',
                          repeat: true,
                          width: lottieSize,
                          height: lottieSize,
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
                        if (widget.iapService.rewardedAdsRemovedNotifier.value) {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Ads Removed'),
                              content: const Text('You have removed rewarded ads. You cannot claim free coins.'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );
                          return;
                        }

                        // Ads available, try to claim coins
                        bool adWatched = await controller.claimFreeCoins(iapService: widget.iapService);
                        if (!mounted) return;
                        if (adWatched) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("You earned 10 coins!")),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Ad not ready. Try again later.")),
                          );
                        }
                      }
                  ),
                ),
                // spin wheel bottom right
                Positioned(
                  bottom: bottomPadding,
                  right: 20,
                  child: GestureDetector(
                    onTap: () {
                      if (controller.canSpin) {
                        showDialog(
                          context: context,
                          builder: (context) => Dialog(
                            backgroundColor: Colors.transparent,
                            insetPadding: const EdgeInsets.all(16),
                            child: Wheel(onSpinCompleted: _onSpinCompleted, iapService: widget.iapService,),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "Next spin available in ${controller.formatCooldown(controller.remainingCooldown)} minutes",
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
                          width: lottieSize,
                          height: lottieSize,
                        ),
                        const SizedBox(width: 8),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
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
