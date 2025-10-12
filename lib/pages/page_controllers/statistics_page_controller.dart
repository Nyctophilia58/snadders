import '../../services/shared_prefs_service.dart';

class StatisticsPageController {
  final SharedPrefsService _prefsService = SharedPrefsService();

  /// Load saved profile image or default first image
  Future<String> loadProfileImage(List<String> defaultImages) async {
    final saved = await _prefsService.loadProfileImage();
    return (saved.isNotEmpty) ? saved : defaultImages.first;
  }

  /// Save profile image
  Future<void> saveProfileImage(String path) async {
    await _prefsService.saveProfileImage(path);
  }

  /// Save username
  Future<void> saveUsername(String username, bool isGuest) async {
    if (username.isNotEmpty) {
      await _prefsService.saveUsername(username, isGuest: isGuest);
    }
  }
}
