import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:snadders/services/google_play_services.dart';
import 'package:snadders/services/shared_prefs_service.dart';

import '../../widgets/active_status_wrapper.dart';

class SignInPageController {
  final SharedPrefsService _prefsService = SharedPrefsService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Checks username in both collections
  Future<bool> _isUsernameTaken(String username) async {
    username = username.toLowerCase();
    final googleQuery = await _firestore
        .collection('googleUsers')
        .where('username', isEqualTo: username)
        .get();

    final guestQuery = await _firestore
        .collection('guestUsers')
        .where('username', isEqualTo: username)
        .get();

    return googleQuery.docs.isNotEmpty || guestQuery.docs.isNotEmpty;
  }

  /// Sign in with Google using username only
  Future<String?> signInWithGoogle() async {
    await GooglePlayServices.signIn();
    final username = await GooglePlayServices.getUsername();
    if (username == null || username.isEmpty) return null;

    // Check if username exists globally
    final usernameExists = await _isUsernameTaken(username);
    if (usernameExists) {
      // Existing user found in either collection
      // Fetch user data (Google only, since this is a Google login)
      final query = await _firestore
          .collection('googleUsers')
          .where('username', isEqualTo: username)
          .get();

      if (query.docs.isNotEmpty) {
        final data = query.docs.first.data();
        final docId = query.docs.first.id;

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
          profileImage: data['profileImage'],
          isDeleted: false,
          isInLobby: data['isInLobby'],
          gamesPlayed: data['gamesPlayed'],
          gamesWon: data['gamesWon'],
          winRate: data['winRate'],
        );
        ActiveStatusWrapper.updateUser(userId: docId, isGuest: false);
        return username;
      }

      // If somehow username exists only in guestUsers → reject to avoid collision
      return null;
    }

    // New user: create in Firestore and SharedPrefs
    final defaultCoins = 500;
    final defaultDiamonds = 25;
    final defaultBoards = [0, 1, 2];
    final defaultProfileImage = 'assets/images/persons/01.png';

    final docRef = await _firestore.collection('googleUsers').add({
      'username': username,
      'isGuest': false,
      'coins': defaultCoins,
      'diamonds': defaultDiamonds,
      'allAdsRemoved': false,
      'rewardedAdsRemoved': false,
      'boardsUnlocked': defaultBoards,
      'hasRated': false,
      'profileImage': defaultProfileImage,
      'isInLobby': false,
      'gamesPlayed': 0,
      'gamesWon': 0,
      'winRate': 0.0,
    });

    final docId = docRef.id;

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
      profileImage: defaultProfileImage,
      isDeleted: false,
      isInLobby: false,
      gamesPlayed: 0,
      gamesWon: 0,
      winRate: 0.0,
    );
    ActiveStatusWrapper.updateUser(userId: docId, isGuest: false);
    return username;
  }

  // Play as Guest
  Future<String?> playAsGuest(String username) async {
    if (username.isEmpty) return null;

    // Global duplicate username check
    final usernameExists = await _isUsernameTaken(username);
    if (usernameExists) {
      return null;
    }

    final defaultCoins = 500;
    final defaultDiamonds = 25;
    final defaultBoards = [0, 1, 2];
    final defaultProfileImage = 'assets/images/persons/01.png';

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
      'profileImage': defaultProfileImage,
      'isInLobby': false,
      'gamesPlayed': 0,
      'gamesWon': 0,
      'winRate': 0.0,
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
      profileImage: defaultProfileImage,
      isDeleted: true,
      isInLobby: false,
      gamesPlayed: 0,
      gamesWon: 0,
      winRate: 0.0,
    );

    return username;
  }

  // Helper to save all fields in SharedPrefs
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
    required String profileImage,
    required bool isDeleted,
    required bool isInLobby,
    required int gamesPlayed,
    required int gamesWon,
    required double winRate,
  }) async {
    await _prefsService.saveUserId(docId);
    await _prefsService.saveUsername(username, isGuest: isGuest);
    await _prefsService.saveCoins(coins);
    await _prefsService.saveDiamonds(diamonds);
    await _prefsService.setAllAdsRemoved(allAdsRemoved);
    await _prefsService.setRewardedAdsRemoved(rewardedAdsRemoved);
    await _prefsService.setRated(hasRated);
    await _prefsService.saveProfileImage(profileImage);
    await _prefsService.setAccountDeleted(isDeleted);
    await _prefsService.setLobbyStatus(isInLobby);
    await _prefsService.saveGamesPlayed(gamesPlayed);
    await _prefsService.saveGamesWon(gamesWon);
    await _prefsService.saveWinRate(winRate);

    for (int i = 0; i < boardsUnlocked.length; i++) {
      bool unlocked = boardsUnlocked.contains(i);
      await _prefsService.saveBoardUnlocked(i, unlocked);
    }
  }
}
