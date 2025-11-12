import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/sign_in_state_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/shared_prefs_service.dart';

class SplashScreenController {
  final WidgetRef ref;
  final SharedPrefsService _prefsService = SharedPrefsService(); // ← Add this
  SplashScreenController(this.ref);

  /// Safe async initialization with mounted check
  Future<void> initializeAppSafe({required bool Function() mountedCheck}) async {
    final signInNotifier = ref.read(signInProvider.notifier);

    // Check Google sign-in
    if (!mountedCheck()) return;
    await signInNotifier.checkSignInGoogle();

    final signInState = ref.read(signInProvider);
    if (signInState.signedIn && !signInState.isGuest) {
      final username = signInState.username;
      if (username.isNotEmpty) {
        // Sync all user data from Firestore to local storage
        await _syncUserDataFromFirestore(username);
      }
    }

    // Check guest sign-in if not signed in with Google
    if (!mountedCheck()) return;
    if (!ref.read(signInProvider).signedIn) {
      await signInNotifier.checkSignInGuest();
    }

    // Optional splash delay
    if (!mountedCheck()) return;
    await Future.delayed(const Duration(seconds: 3));
  }

  // Sync all user data from Firestore to local storage
  Future<void> _syncUserDataFromFirestore(String username) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final prefs = await SharedPreferences.getInstance();

      final query = await firestore
          .collection('googleUsers')
          .where('username', isEqualTo: username)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        final doc = query.docs.first;
        final data = doc.data();

        // Core fields
        await prefs.setInt('coins', data['coins'] ?? SharedPrefsService.defaultCoins);
        await prefs.setInt('diamonds', data['diamonds'] ?? SharedPrefsService.defaultDiamonds);
        await prefs.setString('profileImage', data['profileImage'] ?? SharedPrefsService.defaultProfileImage);
        await prefs.setString('userId', doc.id);

        // Extra fields
        await _prefsService.setAllAdsRemoved(data['allAdsRemoved'] ?? false);
        await _prefsService.setRewardedAdsRemoved(data['rewardedAdsRemoved'] ?? false);
        await _prefsService.setRated(data['hasRated'] ?? false);

        // Boards unlocked
        final boardsUnlocked = List<int>.from(data['boardsUnlocked'] ?? [0, 1, 2]);
        for (int i = 0; i < boardsUnlocked.length; i++) {
          bool unlocked = boardsUnlocked.contains(i);
          await _prefsService.saveBoardUnlocked(i, unlocked);
        }

      } else {
        print("No Firestore document found for username: $username");
      }
    } catch (e) {
      print("Error fetching user data from Firestore: $e");
    }
  }

  bool isSignedIn() => ref.read(signInProvider).signedIn;

  String getUsername() => ref.read(signInProvider).username;

  bool getIsGuest() => ref.read(signInProvider).isGuest;
}
