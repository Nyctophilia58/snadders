import 'package:flutter/material.dart';
import 'package:snadders/services/google_play_services.dart';
import 'guest_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Card(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28), // more expressive rounding
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FilledButton.icon(
                  onPressed: () {
                    GooglePlayServices.signIn();
                  },
                  icon: const Icon(Icons.login),
                  label: const Text("Sign in with Google"),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                OutlinedButton(
                  onPressed: () {
                    // Navigate to guest play screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const GuestPage()),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text("Play as Guest"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
