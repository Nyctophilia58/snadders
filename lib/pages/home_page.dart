import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:snadders/pages/coin_selection_online_page.dart';
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
import 'coin_selection_friends_page.dart';
import 'lobby_page.dart';

class HomePage extends StatefulWidget {
  final String username;
  final bool isGuest;

  const HomePage({
    super.key,
    required this.username,
    required this.isGuest,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late HomePageController controller;
  late IAPService iapService;
  bool _iapInitialized = false;

  @override
  void initState() {
    super.initState();
    controller = HomePageController();
    WidgetsBinding.instance.addObserver(this);
    controller.init(initialUsername: widget.username).then((_) => setState(() {}));
    _initIAP();
  }

  Future<void> _initIAP() async {
    iapService = IAPService();
    await iapService.initialize();

    if (!mounted) return;

    // Optionally restore previous purchases or consumables
    // await iapService.restorePurchases();

    setState(() => _iapInitialized = true);
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
    if (!_iapInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

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
                      _buildHeader(),
                      const SizedBox(height: 16),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: _buildMainContent(bottomPadding),
                        ),
                      ),
                    ],
                  ),
                ),
                _buildFreeCoinsButton(bottomPadding, lottieSize),
                _buildSpinWheelButton(bottomPadding, lottieSize),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepPurple, Colors.purpleAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3)),
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
                        fontSize: 16),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.monetization_on,
                          color: Colors.yellow, size: 18),
                      const SizedBox(width: 4),
                      ValueListenableBuilder<int>(
                        valueListenable: iapService.coinsNotifier,
                        builder: (context, coins, _) {
                          if (!mounted) return const SizedBox();
                          return Text('$coins',
                              style: const TextStyle(color: Colors.white));
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
              const Icon(Icons.diamond, color: Colors.lightBlueAccent),
              const SizedBox(width: 4),
              ValueListenableBuilder<int>(
                valueListenable: iapService.diamondsNotifier,
                builder: (context, diamonds, _) {
                  if (!mounted) return const SizedBox();
                  return Text('$diamonds',
                      style: const TextStyle(color: Colors.white));
                },
              ),
              const SizedBox(width: 12),
              IconButton(
                icon: const Icon(Icons.store, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          StorePage(initialTabIndex: 0, iapService: iapService),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(double bottomPadding) {
    return Column(
      children: [
        if (!widget.isGuest) const SizedBox(height: 60) else const SizedBox(height: 100),
        Image.asset('assets/logo/foreground.png', width: 150, height: 150),
        const SizedBox(height: 20),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 20,
          runSpacing: 20,
          children: [
            if (!widget.isGuest)
              _buildButton('PLAY ONLINE', Icons.people, _onPlayOnline),
            if (!widget.isGuest)
              _buildButton('PLAY WITH FRIENDS', Icons.people, _onPlayWithFriends),
            _buildButton('VS COMPUTER', Icons.smart_toy, _onPlayVsComputer),
            _buildButton('PASS N PLAY', Icons.group, _onPassNPlay),
          ],
        ),
        const SizedBox(height: 30),
        _buildBottomRow(bottomPadding),
      ],
    );
  }

  Widget _buildBottomRow(double bottomPadding) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildSmallButton('Scores', Icons.emoji_events, () {}),
        const SizedBox(width: 10),
        _buildSmallButton('Settings', Icons.settings, () {
          showDialog(
            context: context,
            builder: (context) => Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.all(16),
              child: SettingsPage(username: widget.username, iapService: iapService),
            ),
          );
        }),
        const SizedBox(width: 10),
        ValueListenableBuilder<bool>(
          valueListenable: iapService.allAdsRemovedNotifier,
          builder: (context, allRemoved, _) {
            return ValueListenableBuilder<bool>(
              valueListenable: iapService.rewardedAdsRemovedNotifier,
              builder: (context, rewardedRemoved, _) {
                if (allRemoved && rewardedRemoved) return const SizedBox.shrink();
                return _buildSmallButton(
                  'Remove ADs',
                  Icons.video_library,
                      () async {
                    await showAdRemovalSelectionDialog(context, iapService);
                    setState(() {});
                  },
                  showFire: true,
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildFreeCoinsButton(double bottomPadding, double lottieSize) {
    return Positioned(
      bottom: bottomPadding,
      left: 20,
      child: GestureDetector(
        onTap: () async {
          if (iapService.rewardedAdsRemovedNotifier.value) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Ads Removed'),
                content: const Text(
                    'You have removed rewarded ads. You cannot claim free coins.'),
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

          bool adWatched = await controller.claimFreeCoins(iapService: iapService);
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(adWatched
                    ? "You earned 10 coins!"
                    : "Ad not ready. Try again later.")),
          );
        },
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
                    Shadow(blurRadius: 10, color: Colors.yellowAccent, offset: Offset(0, 2))
                  ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpinWheelButton(double bottomPadding, double lottieSize) {
    return Positioned(
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
                child: Wheel(onSpinCompleted: _onSpinCompleted, iapService: iapService),
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

  // Button actions
  void _onPlayOnline() async {
    final selectedCoins = await showDialog<int>(
      context: context,
      barrierColor: Colors.black38,
      builder: (context) => CoinSelectionOnlinePage(
        coins: iapService.coinsNotifier.value ?? 0,
        diamonds: iapService.diamondsNotifier.value ?? 0,
      ),
    );
    if (selectedCoins != null) {
      showDialog(
        context: context,
        barrierColor: Colors.black38,
        builder: (context) => LobbyPage(
          iapService: iapService,
          username: controller.username,
          stakeCoins: selectedCoins,
          imagePath: controller.profileImagePath,
        ),
      );
    }
  }

  void _onPlayWithFriends() async {
    await showDialog<int>(
      context: context,
      barrierColor: Colors.black38,
      builder: (context) => CoinSelectionFriendsPage(
        iapService: iapService,
        coins: iapService.coinsNotifier.value ?? 0,
        diamonds: iapService.diamondsNotifier.value ?? 0,
      ),
    );
  }

  void _onPlayVsComputer() async {
    final selectedBoardIndex = await showDialog<int>(
      context: context,
      builder: (context) => BoardSelector(iapService: iapService),
    );
    if (selectedBoardIndex != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PlayVsComputer(
            username: controller.username,
            boardIndex: selectedBoardIndex,
            allAdsRemoved: iapService.allAdsRemovedNotifier.value,
          ),
        ),
      );
    }
  }

  void _onPassNPlay() async {
    final selectedBoardIndex = await showDialog<int>(
      context: context,
      builder: (context) => BoardSelector(iapService: iapService),
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
              allAdsRemoved: iapService.allAdsRemovedNotifier.value,
            ),
          ),
        );
      }
    }
  }
}
