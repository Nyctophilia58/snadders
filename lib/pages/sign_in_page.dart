import 'dart:io';
import 'package:flutter/material.dart';
import 'package:snadders/pages/page_controllers/sign_in_page_controller.dart';
import '../services/shared_prefs_service.dart';
import '../widgets/exit_button.dart';
import '../pages/home_page.dart';

class SignInPage extends StatelessWidget {
  SignInPage({super.key});

  final SignInPageController controller = SignInPageController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.greenAccent, Colors.blueAccent],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // App Icon
                      Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/icons/app_icon.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),

                      // Title
                      Text(
                        "Start Your Adventure",
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onBackground,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),

                      // Buttons Card
                      Card(
                        color: Colors.white,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              // Google Sign-In Button
                              FilledButton.icon(
                                onPressed: () async {
                                  final username = await controller.signInWithGoogle();
                                  if (username != null) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => HomePage(username: username, isGuest: false),
                                      ),
                                    );
                                  }
                                },
                                icon: const Icon(Icons.login, color: Colors.white),
                                label: const Text("Sign in with Google", style: TextStyle(color: Colors.white)),
                                style: FilledButton.styleFrom(
                                  minimumSize: const Size(double.infinity, 56),
                                  backgroundColor: Colors.deepPurple,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  textStyle: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  elevation: 5,
                                  shadowColor: Colors.deepPurpleAccent.withOpacity(0.3),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                "OR",
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 10),

                              // Play as Guest Button
                              OutlinedButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      String playerName = "";
                                      return AlertDialog(
                                        title: const Text("Enter your username"),
                                        content: TextField(
                                          onChanged: (value) => playerName = value,
                                          decoration: const InputDecoration(hintText: "Username"),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context),
                                            child: const Text("Cancel"),
                                          ),
                                          ElevatedButton(
                                            onPressed: () async {
                                              if (playerName.isNotEmpty) {
                                                await controller.playAsGuest(playerName);
                                                Navigator.pop(context);
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (_) => HomePage(username: playerName, isGuest: true),
                                                  ),
                                                );
                                              }
                                            },
                                            child: const Text("Continue"),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size(double.infinity, 56),
                                  side: BorderSide(
                                    color: theme.colorScheme.primary,
                                    width: 2,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  textStyle: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                child: const Text("Play as Guest", style: TextStyle(color: Colors.deepPurpleAccent)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Exit Button
            Positioned(
              bottom: 20,
              left: 20,
              child: ExitButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) {
                      return AlertDialog(
                        title: const Text("Exit App"),
                        content: const Text("Are you sure you want to exit?"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Cancel"),
                          ),
                          ElevatedButton(
                            onPressed: () => exit(0),
                            child: const Text("Exit"),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
