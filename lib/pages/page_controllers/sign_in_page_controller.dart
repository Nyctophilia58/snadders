import 'package:snadders/services/google_play_services.dart';
import 'package:snadders/services/shared_prefs_service.dart';

class SignInPageController {
  final SharedPrefsService _prefsService = SharedPrefsService();

  Future<String?> signInWithGoogle() async {
    await GooglePlayServices.signIn();
    final username = await GooglePlayServices.getUsername();
    if (username != null && username.isNotEmpty) {
      await _prefsService.saveUsername(username, isGuest: false);
      return username;
    }
    return null;
  }

  Future<void> playAsGuest(String username) async {
    if (username.isNotEmpty) {
      await _prefsService.saveUsername(username, isGuest: true);
    }
  }
}
