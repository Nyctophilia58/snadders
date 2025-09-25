import 'package:flutter/material.dart';

class SpinChoiceCard extends StatelessWidget {
  final VoidCallback onCoinsSelected;
  final VoidCallback onDiamondsSelected;

  const SpinChoiceCard({
    super.key,
    required this.onCoinsSelected,
    required this.onDiamondsSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        color: Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Choose Spin Type",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: onCoinsSelected,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black,
                    ),
                    child: const Text("Coins"),
                  ),
                  ElevatedButton(
                    onPressed: onDiamondsSelected,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("Diamonds"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
