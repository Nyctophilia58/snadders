import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/sign_in_state_provider.dart';

class SplashController {
  final WidgetRef ref;
  SplashController(this.ref);

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
  }

  bool isSignedIn() => ref.read(signInProvider).signedIn;

  String getUsername() => ref.read(signInProvider).username;

  bool getIsGuest() => ref.read(signInProvider).isGuest;
}
