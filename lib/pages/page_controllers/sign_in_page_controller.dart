import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:snadders/services/google_play_services.dart';
import 'package:snadders/services/shared_prefs_service.dart';

class SignInPageController {
  final SharedPrefsService _prefsService = SharedPrefsService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Sign in with Google using username only
  Future<String?> signInWithGoogle() async {
    await GooglePlayServices.signIn();
    final username = await GooglePlayServices.getUsername();
    if (username == null || username.isEmpty) return null;

    // Check if username exists in googleUsers
    final query = await _firestore
        .collection('googleUsers')
        .where('username', isEqualTo: username)
        .get();

    String docId;

    if (query.docs.isNotEmpty) {
      // Existing user: fetch data and save to SharedPrefs
      final data = query.docs.first.data();
      docId = query.docs.first.id;
      await _saveToSharedPrefs(
        docId: docId,
        username: data['username'],
        isGuest: false,
        coins: data['coins'],
        diamonds: data['diamonds'],
        allAdsRemoved: data['allAdsRemoved'],
        rewardedAdsRemoved: data['rewardedAdsRemoved'],
        boardsUnlocked: List<int>.from(data['boardsUnlocked']),
        hasRated: data['hasRated'],
      );
    } else {
      // New user: create in Firestore and SharedPrefs
      final defaultCoins = 500;
      final defaultDiamonds = 25;
      final defaultBoards = [0, 1, 2];

      final docRef = await _firestore.collection('googleUsers').add({
        'username': username,
        'isGuest': false,
        'coins': defaultCoins,
        'diamonds': defaultDiamonds,
        'allAdsRemoved': false,
        'rewardedAdsRemoved': false,
        'boardsUnlocked': defaultBoards,
        'hasRated': false,
      });

      docId = docRef.id;

      await _saveToSharedPrefs(
        docId: docId,
        username: username,
        isGuest: false,
        coins: defaultCoins,
        diamonds: defaultDiamonds,
        allAdsRemoved: false,
        rewardedAdsRemoved: false,
        boardsUnlocked: defaultBoards,
        hasRated: false,
      );
    }

    return username;
  }

  /// Play as Guest
  Future<String?> playAsGuest(String username) async {
    if (username.isEmpty) return null;

    // Check duplicate username in guestUsers
    final query = await _firestore
        .collection('guestUsers')
        .where('username', isEqualTo: username)
        .get();

    if (query.docs.isNotEmpty) {
      // Duplicate username
      return null;
    }

    final defaultCoins = 500;
    final defaultDiamonds = 25;
    final defaultBoards = [0, 1, 2];

    // Save to Firestore
    final docRef = await _firestore.collection('guestUsers').add({
      'username': username,
      'isGuest': true,
      'coins': defaultCoins,
      'diamonds': defaultDiamonds,
      'allAdsRemoved': false,
      'rewardedAdsRemoved': false,
      'boardsUnlocked': defaultBoards,
      'hasRated': false,
    });

    final docId = docRef.id;

    // Save to SharedPrefs
    await _saveToSharedPrefs(
      docId: docId,
      username: username,
      isGuest: true,
      coins: defaultCoins,
      diamonds: defaultDiamonds,
      allAdsRemoved: false,
      rewardedAdsRemoved: false,
      boardsUnlocked: defaultBoards,
      hasRated: false,
    );

    return username;
  }

  /// Helper to save all fields in SharedPrefs
  Future<void> _saveToSharedPrefs({
    required String docId,
    required String username,
    required bool isGuest,
    required int coins,
    required int diamonds,
    required bool allAdsRemoved,
    required bool rewardedAdsRemoved,
    required List<int> boardsUnlocked,
    required bool hasRated,
  }) async {
    await _prefsService.saveUserId(docId);
    await _prefsService.saveUsername(username, isGuest: isGuest);
    await _prefsService.saveCoins(coins);
    await _prefsService.saveDiamonds(diamonds);
    await _prefsService.setAllAdsRemoved(allAdsRemoved);
    await _prefsService.setRewardedAdsRemoved(rewardedAdsRemoved);
    await _prefsService.setRated(hasRated);

    // Save boards
    for (int i = 0; i < boardsUnlocked.length; i++) {
      bool unlocked = boardsUnlocked.contains(i);
      await _prefsService.saveBoardUnlocked(i, unlocked);
    }
  }
}
