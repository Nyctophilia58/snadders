import 'dart:io';
import 'package:flutter/material.dart';
import 'package:snadders/pages/page_controllers/sign_in_page_controller.dart';
import 'package:snadders/services/iap_services.dart';
import '../widgets/buttons/exit_button.dart';
import '../pages/home_page.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final SignInPageController controller = SignInPageController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _navigateToHome(String username, bool isGuest) async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => HomePage(
          username: username,
          isGuest: isGuest,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: Stack(
          children: [
            // Background
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
                  child: SingleChildScrollView(
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
                                  onPressed: _isLoading
                                      ? null
                                      : () async {
                                    setState(() => _isLoading = true);
                                    final username = await controller.signInWithGoogle();
                                    setState(() => _isLoading = false);

                                    if (username != null) {
                                      await _navigateToHome(username, false);
                                    }
                                  },
                                  icon: const Icon(Icons.login, color: Colors.white),
                                  label: const Text(
                                    "Sign in with Google",
                                    style: TextStyle(color: Colors.white),
                                  ),
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
                                  onPressed: _isLoading
                                      ? null
                                      : () {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        String playerName = "";
                                        return AlertDialog(
                                          title: const Text("Enter your username"),
                                          content: TextField(
                                            onChanged: (value) => playerName = value,
                                            decoration: const InputDecoration(
                                              hintText: "Username",
                                            ),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(context),
                                              child: const Text("Cancel"),
                                            ),
                                            ElevatedButton(
                                              onPressed: () async {
                                                if (playerName.isNotEmpty) {
                                                  final result = await controller.playAsGuest(playerName);
                                                  if (result == null) {
                                                    // Show error for duplicate username
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      const SnackBar(
                                                        content: Text("Username already taken. Please choose another."),
                                                      ),
                                                    );
                                                    return;
                                                  }
                                                  Navigator.pop(context);
                                                  await _navigateToHome(playerName, true);
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
                                  child: const Text(
                                    "Play as Guest",
                                    style: TextStyle(color: Colors.deepPurpleAccent),
                                  ),
                                ),
                                // if (_isLoading)
                                //   const Padding(
                                //     padding: EdgeInsets.only(top: 16),
                                //     child: CircularProgressIndicator(),
                                //   ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
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
