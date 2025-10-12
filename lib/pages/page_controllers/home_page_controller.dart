import 'dart:async';
import '../../services/ad_services/ad_interstitial_service.dart';
import '../../services/ad_services/ad_reward_service.dart';
import '../../services/shared_prefs_service.dart';

class HomePageController {
  final SharedPrefsService _prefsService = SharedPrefsService();

  int coins = 0;
  int diamonds = 0;
  int remainingCooldown = 0;
  bool canSpin = true;
  String profileImagePath = SharedPrefsService.defaultProfileImage;
  String username = '';
  Timer? _cooldownTimer;

  Future<void> init({required String initialUsername}) async {
    username = initialUsername;
    await _loadCoins();
    await _loadDiamonds();
    await _checkSpin();
    await loadProfileImage();
    await loadUsername();
    AdRewardService.loadRewardedAd();
    AdInterstitialService.loadInterstitialAd();
  }

  Future<void> _loadCoins() async {
    coins = await _prefsService.loadCoins();
  }

  Future<void> _loadDiamonds() async {
    diamonds = await _prefsService.loadDiamonds();
  }

  Future<void> _checkSpin() async {
    canSpin = await _prefsService.canSpin();
    remainingCooldown = await _prefsService.getRemainingCooldown();
    if (!canSpin) {
      _startCooldownTimer();
    }
  }

  Future<void> loadProfileImage() async {
    profileImagePath = await _prefsService.loadProfileImage();
  }

  Future<void> loadUsername() async {
    final savedUsername = await _prefsService.loadUsername();
    if (savedUsername != null && savedUsername.isNotEmpty) {
      username = savedUsername;
    }
  }

  Future<void> onSpinCompleted() async {
    await _loadCoins();
    await _loadDiamonds();
    await _prefsService.saveLastSpinTimestamp(
        DateTime.now().millisecondsSinceEpoch);
    await _checkSpin();
  }

  void _startCooldownTimer() {
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      remainingCooldown = await _prefsService.getRemainingCooldown();
      if (remainingCooldown == 0) {
        canSpin = true;
        timer.cancel();
      }
    });
  }

  Future<bool> claimFreeCoins() async {
    final adWatched = await AdRewardService.showRewardedAd();
    if (adWatched) {
      coins += 10;
      await _prefsService.saveCoins(coins);
    }
    return adWatched;
  }

  String formatCooldown(int millis) {
    final seconds = millis ~/ 1000;
    final minutes = seconds ~/ 60;
    return minutes.toString().padLeft(2, '0');
  }

  void dispose() {
    _cooldownTimer?.cancel();
  }
}
