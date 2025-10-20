import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import '../../services/shared_prefs_service.dart';

class SettingsPageController {
  bool soundEnabled = true;
  String selectedLanguage = 'English';
  String selectedBoard = 'Classic';

  final List<String> boardThemes = ['Classic', 'Ocean', 'Forest', 'Candy'];
  final List<String> languages = ['English', 'Bangla'];

  final SharedPrefsService _prefsService = SharedPrefsService();

  void toggleSound(bool value) {
    soundEnabled = value;
  }

  void selectLanguage(String language) {
    selectedLanguage = language;
  }

  void selectBoard(String board) {
    selectedBoard = board;
  }

  void openStore() {}
  void openHelpSupport() {}
  void openNotifications() {}
  void troubleshoot() {}
  void requestAccountDeletion() {}
  void shareApp() {}

  /// Rate Us with already-rated check
  Future<void> rateUs(BuildContext context) async {
    final InAppReview inAppReview = InAppReview.instance;
    final hasRated = await _prefsService.getRated() ?? false;

    if (hasRated) {
      // Already rated → just show a message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You've already rated the app.")),
      );
      return;
    }

    // Try to show in-app review
    if (await inAppReview.isAvailable()) {
      try {
        await inAppReview.requestReview(); // show in-app popup
      } catch (_) {
        await inAppReview.openStoreListing(); // fallback
      }
    } else {
      await inAppReview.openStoreListing(); // fallback
    }

    // Save that user has rated
    await _prefsService.setRated(true);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Thank you for rating!")),
    );
  }
}
