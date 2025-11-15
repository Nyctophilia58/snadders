import 'package:flutter/material.dart';

class ExitButton extends StatelessWidget {
  final VoidCallback onPressed;

  const ExitButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.redAccent.withOpacity(0.6),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Image.asset(
          'assets/icons/exit.png',
          width: 30,
          height: 30,
          color: Colors.white,
        ),
      ),
    );
  }
}
