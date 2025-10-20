import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsService {
  static const String _coinsKey = 'coins';
  static const String _diamondsKey = 'diamonds';
  static const String _lastSpinTimestampKey = 'last_spin_timestamp';
  static const String _usernameKey = 'username';
  static const String _isGuestKey = 'isGuest';
  static const String _profileImageKey = 'profileImage';
  static const String _boardKeyPrefix = 'board_';
  static const String _ratedKey = 'hasRated';


  static const String defaultProfileImage = 'assets/images/persons/01.png';
  static const int defaultCoins = 500;
  static const int defaultDiamonds = 25;

  // Load coins
  Future<int> loadCoins() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_coinsKey) ?? defaultCoins;
    } catch (e) {
      return defaultCoins;
    }
  }

  // Save coins
  Future<void> saveCoins(int coins) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_coinsKey, coins);
    } catch (e) {
      print('Error saving coins: $e');
    }
  }

  // Load diamonds
  Future<int> loadDiamonds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_diamondsKey) ?? defaultDiamonds;
    } catch (e) {
      return defaultDiamonds;
    }
  }

  // Save diamonds
  Future<void> saveDiamonds(int diamonds) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_diamondsKey, diamonds);
    } catch (e) {
      print('Error saving diamonds: $e');
    }
  }

  // Spin cooldown
  Future<void> saveLastSpinTimestamp(int timestamp) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_lastSpinTimestampKey, timestamp);
    } catch (e) {
      print('Error saving timestamp: $e');
    }
  }

  // Check if user can spin (1 hour cooldown)
  Future<bool> canSpin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastSpinTimestamp = prefs.getInt(_lastSpinTimestampKey) ?? 0;
      final currentTimestamp = DateTime.now().millisecondsSinceEpoch;
      const oneHourInMillis = 60 * 60 * 1000;
      return currentTimestamp - lastSpinTimestamp >= oneHourInMillis;
    } catch (e) {
      return true;
    }
  }

  // Get remaining cooldown time in milliseconds
  Future<int> getRemainingCooldown() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastSpinTimestamp = prefs.getInt(_lastSpinTimestampKey) ?? 0;
      final currentTimestamp = DateTime.now().millisecondsSinceEpoch;
      const oneHourInMillis = 60 * 60 * 1000;
      final diff = oneHourInMillis - (currentTimestamp - lastSpinTimestamp);
      return diff > 0 ? diff : 0;
    } catch (e) {
      return 0;
    }
  }

  // Save username and guest status
  Future<void> saveUsername(String username, {bool isGuest = false}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_usernameKey, username);
      await prefs.setBool(_isGuestKey, isGuest);
    } catch (e) {
      print('Error saving username: $e');
    }
  }

  // Load username
  Future<String?> loadUsername() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_usernameKey);
    } catch (e) {
      return null;
    }
  }

  // Load guest status
  Future<bool> loadIsGuest() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_isGuestKey) ?? true;
    } catch (e) {
      return true;
    }
  }

// Load Profile image
  Future<String> loadProfileImage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_profileImageKey) ?? defaultProfileImage;
    } catch (e) {
      print('Error loading profile image: $e');
      return defaultProfileImage;
    }
  }

// Save Profile image
  Future<void> saveProfileImage(String imagePath) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_profileImageKey, imagePath);
    } catch (e) {
      print('Error saving profile image: $e');
    }
  }

  Future<void> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_coinsKey);
      await prefs.remove(_diamondsKey);
      await prefs.remove(_lastSpinTimestampKey);
      await prefs.remove(_usernameKey);
      await prefs.remove(_isGuestKey);
      await prefs.remove(_profileImageKey);
    } catch (e) {
      print('Error clearing data: $e');
    }
  }

  Future<bool> loadAllAdsRemoved() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('isAllAdsRemoved') ?? false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> loadRewardedAdsRemoved() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('isRewardedAdsRemoved') ?? false;
    } catch (e) {
      return false;
    }
  }

  Future<void> setAllAdsRemoved(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isAllAdsRemoved', value);
  }

  Future<void> setRewardedAdsRemoved(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isRewardedAdsRemoved', value);
  }

  // Save if a board is unlocked
  Future<void> saveBoardUnlocked(int boardIndex, bool unlocked) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('$_boardKeyPrefix$boardIndex', unlocked);
    } catch (e) {
      print('Error saving board $boardIndex: $e');
    }
  }

  // Load if a board is unlocked (default false if not set)
  Future<bool> loadBoardUnlocked(int boardIndex) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('$_boardKeyPrefix$boardIndex') ?? false;
    } catch (e) {
      return false;
    }
  }

  // Load all boards ownership
  Future<List<bool>> loadAllBoards(int totalBoards) async {
    List<bool> boards = [];
    for (int i = 0; i < totalBoards; i++) {
      boards.add(await loadBoardUnlocked(i));
    }
    return boards;
  }

  // Set rated
  Future<void> setRated(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_ratedKey, value);
  }

  // Get rated
  Future<bool?> getRated() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_ratedKey);
  }
}
