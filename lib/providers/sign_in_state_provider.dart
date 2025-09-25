import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snadders/services/google_play_services.dart';

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
  SignInNotifier() : super(SignInState(signedIn: false, username: ""));

  Future<void> checkSignInGoogle() async {
    final signedIn = await GooglePlayServices.isSignedIn();
    String username = "";
    if (signedIn) {
      username = await GooglePlayServices.getUsername();
    }
    state = state.copyWith(signedIn: signedIn, username: username);
  }

  Future<void> checkSignInGuest() async {
    final prefs = await SharedPreferences.getInstance();
    final guestSignedIn = prefs.getBool('guestSignedIn') ?? false;
    if (guestSignedIn) {
      final username = prefs.getString('guestUsername') ?? "Guest";
      state = state.copyWith(signedIn: true, username: username, isGuest: true);
    }
  }
}

// Provider
final signInProvider = StateNotifierProvider<SignInNotifier, SignInState>(
    (ref) => SignInNotifier(),
);
