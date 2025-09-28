import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import '../providers/sign_in_state_provider.dart';
import 'home_page.dart';
import 'sign_in_page.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  void _initApp() async {
    final signInNotifier = ref.read(signInProvider.notifier);

    // Check Google sign-in
    await signInNotifier.checkSignInGoogle();

    // Check guest sign-in if not signed in with Google
    if (!ref.read(signInProvider).signedIn) {
      await signInNotifier.checkSignInGuest();
    }

    // Splash screen delay
    await Future.delayed(const Duration(seconds: 5));

    // Read updated state
    final state = ref.read(signInProvider);

    if (state.signedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomePage(username: state.username, isGuest: state.isGuest),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => SignInPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white.withOpacity(0.5)
                            : Colors.green.withOpacity(0.5),
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  width: 280,
                  height: 280,
                ),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Lottie.asset(
                      'assets/animations/snake.json',
                      repeat: true,
                      width: 250,
                      height: 250,
                    ),
                    Positioned(
                      right: 15,
                      child: Image.asset(
                        'assets/images/ladders/08.png',
                        width: 170,
                        height: 170,
                      ),
                    ),

                    Positioned(
                      bottom: 10,
                      right: 25,
                      child: Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()..scale(-1.0, 1.0), // horizontal flip
                        child: Lottie.asset(
                          'assets/animations/dice.json',
                          repeat: false,
                          width: 170,
                          height: 170,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Welcome to Snadders...',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 10),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
