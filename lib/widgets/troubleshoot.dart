import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:snadders/pages/contact_us.dart';
import 'buttons/exit_button.dart';

class TroubleShoot extends StatelessWidget {
  final String username;
  const TroubleShoot({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blueGrey.shade200, Colors.teal.shade200, Colors.blue.shade200],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 20,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.deepOrangeAccent.shade100, Colors.orangeAccent.shade200],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        'Troubleshoot',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          shadows: const [
                            Shadow(
                              color: Colors.black87,
                              offset: Offset(1, 1),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Content
                  const Text(
                    'If you are experiencing issues with the app, please try the following steps:\n\n'
                        '1. Restart the app.\n'
                        '2. Clear the app cache from settings.\n'
                        '3. Ensure you have a stable internet connection.\n'
                        '4. Update the app to the latest version.\n'
                        '5. Reinstall the app if problems persist.\n\n',
                    style: TextStyle(fontSize: 16, color: Colors.black87, height: 1.5),
                  ),
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(fontSize: 16, color: Colors.black87, height: 1.5),
                      children: [
                        const TextSpan(
                            text:
                            'If none of these steps resolve your issue, please contact our '),
                        TextSpan(
                          text: 'support team',
                          style: const TextStyle(
                            color: Colors.blueAccent,
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.bold,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ContactUs(username: username),
                                ),
                              );
                            },
                        ),
                        const TextSpan(text: ' for further assistance.'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          ExitButton(
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
