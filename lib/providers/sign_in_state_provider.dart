import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snadders/services/shared_prefs_service.dart';
import '../services/google_play_services.dart';

// State class
class SignInState {
  final bool signedIn;
  final String username;
  final bool isGuest;

  SignInState({required this.signedIn, required this.username, this.isGuest = false});

  SignInState copyWith({bool? signedIn, String? username, bool? isGuest}) {
    return SignInState(
      signedIn: signedIn ?? this.signedIn,
      username: username ?? this.username,
      isGuest: isGuest ?? this.isGuest,
    );
  }
}

// StateNotifier
class SignInNotifier extends StateNotifier<SignInState> {
  final SharedPrefsService _sharedPrefsService = SharedPrefsService();

  SignInNotifier() : super(SignInState(signedIn: false, username: ""));

  Future<void> checkSignInGoogle() async {
    final signedIn = await GooglePlayServices.isSignedIn();
    String? username = "";
    if (signedIn) {
      username = await GooglePlayServices.getUsername();
      await _sharedPrefsService.saveUsername(username!, isGuest: false);
    }
    state = state.copyWith(signedIn: signedIn, username: username, isGuest: false);
  }

  Future<void> checkSignInGuest() async {
    final isGuest = await _sharedPrefsService.loadIsGuest();
    final username = await _sharedPrefsService.loadUsername();

    if (isGuest && username != null) {
      state = state.copyWith(signedIn: true, username: username, isGuest: true);
    }
  }
}

// Provider
final signInProvider = StateNotifierProvider<SignInNotifier, SignInState>(
      (ref) => SignInNotifier(),
);
