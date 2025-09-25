import 'dart:io';
import 'package:flutter/material.dart';
import 'package:snadders/services/google_play_services.dart';
import 'package:snadders/widgets/exit_button.dart';
import '../services/shared_prefs_service.dart';
import 'home_page.dart';

class SignInPage extends StatelessWidget {
  SignInPage({super.key});

  final SharedPrefsService _sharedPrefsService = SharedPrefsService();

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
                      Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: ClipOval(
                          child: Image(
                            image: AssetImage('assets/icons/app_icon.png'),
                            fit: BoxFit.cover,
                            width: 180,
                            height: 180,
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),

                      Text(
                        "Start Your Adventure",
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onBackground,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 32),

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
                              // Sign in with Google Button
                              FilledButton.icon(
                                onPressed: () {
                                  GooglePlayServices.signIn();
                                  // After successful sign-in, get the username
                                  GooglePlayServices.getUsername().then((username) {
                                    _sharedPrefsService.saveUsername(username, isGuest: false);
                                    // Navigate to HomePage
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => HomePage(username: username, isGuest: false),
                                      ),
                                    );
                                  });
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

                              Text("OR", style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey, fontWeight: FontWeight.w600)),

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
                                          onChanged: (value) {
                                            playerName = value;
                                            _sharedPrefsService.saveUsername(playerName, isGuest: true);
                                          },
                                          decoration: const InputDecoration(
                                            hintText: "Username",
                                          ),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: const Text("Cancel"),
                                          ),
                                          ElevatedButton(
                                            onPressed: () async {
                                              if (playerName.isNotEmpty) {
                                                Navigator.pop(context);
                                                // Navigate to HomePage as guest
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => HomePage(username: playerName, isGuest: true)
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
            Positioned(
              bottom: 20,
              left: 20,
              child: ExitButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text("Exit App"),
                        content: const Text("Are you sure you want to exit?"),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text("Cancel"),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              exit(0);
                            },
                            child: const Text("Exit"),
                          ),
                        ],
                      );
                    }
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
