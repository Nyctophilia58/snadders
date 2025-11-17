import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:snadders/widgets/active_status_wrapper.dart';
import '../../providers/sign_in_state_provider.dart';
import '../../services/google_play_services.dart';
import '../../services/shared_prefs_service.dart';
import '../../services/iap_services.dart';
import '../sign_in_page.dart';
import '../store_page.dart';

class SettingsPageController {
  String selectedLanguage = 'English';
  String selectedBoard = 'Classic';

  final List<String> boardThemes = ['Classic', 'Ocean', 'Forest', 'Candy'];
  final List<String> languages = ['English', 'Bangla'];

  final SharedPrefsService _prefsService = SharedPrefsService();

  void openStore(BuildContext context, IAPService iapService) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StorePage(initialTabIndex: 0, iapService: iapService),
      ),
    );
  }

  void openNotifications() {}

  Future<void> requestAccountDeletion(BuildContext context, IAPService iapService) async {
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

    if (confirmed != true) return;
    ActiveStatusWrapper.ignoreActiveStatus = true;

    try {
      final sharedPrefs = SharedPrefsService();
      final userId = await sharedPrefs.getUserId();
      final isGuest = await sharedPrefs.getIsGuest();

      // Delete Firestore doc
      if (userId != null) {
        final collectionName = isGuest ? 'guestUsers' : 'googleUsers';
        await FirebaseFirestore.instance.collection(collectionName).doc(userId).delete();
      }

      // Clear SharedPreferences
      await SharedPrefsService().clearAll();
      // make userId null in SharedPrefsService
      await SharedPrefsService().setUserId('');
      await SharedPrefsService().saveUsername('', isGuest: false);
      await SharedPrefsService().setAccountDeleted(true);

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
    } finally {
      ActiveStatusWrapper.ignoreActiveStatus = false;
    }
  }
}
