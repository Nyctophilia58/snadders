import 'package:flutter/material.dart';

class BoardCard extends StatelessWidget {
  final String name;
  final String progress;
  final String price;

  const BoardCard({super.key, required this.name, required this.progress, required this.price});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.red[800],
      child: Column(
        children: [
          Text(name, style: TextStyle(color: Colors.white)),
          Icon(Icons.play_circle, color: Colors.green), // For Ad
          Text(progress, style: TextStyle(color: Colors.white)),
          Text('OR', style: TextStyle(color: Colors.white)),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: Text(price),
          ),
        ],
      ),
    );
  }
}