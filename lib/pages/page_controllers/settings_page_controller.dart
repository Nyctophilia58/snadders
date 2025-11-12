import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import '../../services/shared_prefs_service.dart';
import '../../services/iap_services.dart';
import '../sign_in_page.dart';
import '../store_page.dart';

class SettingsPageController {
  bool soundEnabled = true;
  String selectedLanguage = 'English';
  String selectedBoard = 'Classic';

  final List<String> boardThemes = ['Classic', 'Ocean', 'Forest', 'Candy'];
  final List<String> languages = ['English', 'Bangla'];

  final SharedPrefsService _prefsService = SharedPrefsService();

  Future<void> loadSettings() async {
    soundEnabled = await _prefsService.getSoundEnabled() ?? true;
    // selectedLanguage = await _prefsService.getSelectedLanguage() ?? 'English';
    // selectedBoard = await _prefsService.getSelectedBoard() ?? 'Classic';
  }

  Future<void> toggleSound(bool value) async {
    soundEnabled = value;
    await _prefsService.saveSoundEnabled(value);
  }

  Future<void> selectLanguage(String language) async {
    selectedLanguage = language;
    // await _prefsService.saveSelectedLanguage(language);
  }

  Future<void> selectBoard(String board) async {
    selectedBoard = board;
    // await _prefsService.saveSelectedBoard(board);
  }

  void openStore(BuildContext context, IAPService iapService) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StorePage(initialTabIndex: 2, iapService: iapService),
      ),
    );
  }
  void openHelpSupport() {}
  void openNotifications() {}
  void troubleshoot() {}

  Future<void> requestAccountDeletion(BuildContext context, IAPService iapService) async {
    // Ask for confirmation first
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirm Deletion"),
        content: const Text(
            "Are you sure you want to delete your account? All your progress, coins, diamonds, boards, and settings will be lost."),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(
              "Delete",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return; // User canceled

    try {
      await _prefsService.clearAll();
      await _prefsService.saveCoins(SharedPrefsService.defaultCoins);
      await _prefsService.saveDiamonds(SharedPrefsService.defaultDiamonds);

      for (int i = 3; i < 8; i++) {
        await _prefsService.saveBoardUnlocked(i, false);
      }

      await _prefsService.setAllAdsRemoved(false);
      await _prefsService.setRewardedAdsRemoved(false);
      await _prefsService.setRated(false);

      iapService.coinsNotifier.value = SharedPrefsService.defaultCoins;
      iapService.diamondsNotifier.value = SharedPrefsService.defaultDiamonds;
      iapService.unlockedBoardsNotifier.value = {};
      iapService.allAdsRemovedNotifier.value = false;
      iapService.rewardedAdsRemovedNotifier.value = false;

      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => SignInPage(),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Error"),
            content: Text("Failed to delete account: $e"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text("OK"),
              ),
            ],
          ),
        );
      }
    }
  }

  void shareApp() {}

  /// Rate Us with already-rated check
  Future<void> rateUs(BuildContext context) async {
    final InAppReview inAppReview = InAppReview.instance;
    final hasRated = await _prefsService.getRated() ?? false;

    if (hasRated) {
      // showDialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Already Rated"),
          content: const Text("You have already rated the app. Thank you!"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK"),
            ),
          ],
        ),
      );
      return;
    }

    if (await inAppReview.isAvailable()) {
      try {
        await inAppReview.requestReview(); // show in-app popup
      } catch (_) {
        await inAppReview.openStoreListing(); // fallback
      }
    } else {
      await inAppReview.openStoreListing(); // fallback
    }

    await _prefsService.setRated(true);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Thank you for rating!"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
}
