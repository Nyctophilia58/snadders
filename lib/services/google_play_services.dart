import 'package:games_services/games_services.dart';
import 'package:flutter/material.dart';

class GooglePlayServices {
  static Future<void> signIn() async {
    try {
      await GamesServices.signIn();
      debugPrint("Signed in successfully.");
    } catch (e) {
      debugPrint("Error signing in to Google Play Games: $e");
    }
  }

  static Future<bool> isSignedIn() async {
    try {
      final signedIn = await GamesServices.isSignedIn;
      return signedIn;
    } catch (e) {
      debugPrint("Error checking sign-in status: $e");
      return false;
    }
  }

  static Future<String?> getUsername() async {
    try {
      final player = await GamesServices.getPlayerName();
      return player;
    } catch (e) {
      debugPrint("Error retrieving username: $e");
      return null;
    }
  }

  static Future<void> showAchievements() async {
    try {
      await GamesServices.showAchievements();
    } catch (e) {
      debugPrint("Error showing achievements: $e");
    }
  }

  static Future<void> unlockAchievement(String achievementId) async {
    try {
      await GamesServices.unlock(achievement: Achievement(androidID: achievementId));
      debugPrint("Achievement unlocked: $achievementId");
    } catch (e) {
      debugPrint("Error unlocking achievement $achievementId: $e");
    }
  }

  static Future<void> showLeaderboards() async {
    try {
      await GamesServices.showLeaderboards();
    } catch (e) {
      debugPrint("Error showing leaderboards: $e");
    }
  }

  static Future<void> submitScore(String leaderboardId, int score) async {
    try {
      await GamesServices.submitScore(
        score: Score(
          androidLeaderboardID: leaderboardId,
          value: score,
        ),
      );
      debugPrint("Score $score submitted to leaderboard $leaderboardId");
    } catch (e) {
      debugPrint("Error submitting score $score to leaderboard $leaderboardId: $e");
    }
  }
}