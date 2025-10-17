import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/sign_in_state_provider.dart';

class SplashScreenController {
  final WidgetRef ref;
  bool _signedIn = false;
  bool _isGuest = false;
  String _username = "";

  SplashScreenController(this.ref);

  Future<void> initializeApp() async {
    final signInNotifier = ref.read(signInProvider.notifier);

    // Check Google sign-in
    await signInNotifier.checkSignInGoogle();

    // Check guest sign-in if not signed in with Google
    if (!ref.read(signInProvider).signedIn) {
      await signInNotifier.checkSignInGuest();
    }

    // Optional splash delay
    await Future.delayed(const Duration(seconds: 3));

    // ✅ cache values here (so we don't use ref after dispose)
    final state = ref.read(signInProvider);
    _signedIn = state.signedIn;
    _isGuest = state.isGuest;
    _username = state.username;
  }

  bool isSignedIn() => _signedIn;
  String getUsername() => _username;
  bool getIsGuest() => _isGuest;
}
