import 'package:flutter/material.dart';

class GuestPage extends StatelessWidget {
  const GuestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Guest Play'),
      ),
      body: const Center(
        child: Text(
          'Welcome, Guest! Enjoy your play session.',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}