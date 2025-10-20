import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/sign_in_state_provider.dart';

class SplashScreenController {
  final WidgetRef ref;
  SplashScreenController(this.ref);

  /// Safe async initialization with mounted check
  Future<void> initializeAppSafe({required bool Function() mountedCheck}) async {
    final signInNotifier = ref.read(signInProvider.notifier);

    // Check Google sign-in
    if (!mountedCheck()) return;
    await signInNotifier.checkSignInGoogle();

    // Check guest sign-in if not signed in with Google
    if (!mountedCheck()) return;
    if (!ref.read(signInProvider).signedIn) {
      await signInNotifier.checkSignInGuest();
    }

    // Optional splash delay
    if (!mountedCheck()) return;
    await Future.delayed(const Duration(seconds: 3));
  }

  bool isSignedIn() => ref.read(signInProvider).signedIn;

  String getUsername() => ref.read(signInProvider).username;

  bool getIsGuest() => ref.read(signInProvider).isGuest;
}
