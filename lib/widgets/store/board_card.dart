import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class BoardCard extends StatelessWidget {
  final String name;
  final String progress;
  final String price;
  final String imagePath;
  final bool isLocked;

  const BoardCard({
    super.key,
    required this.name,
    required this.progress,
    required this.price,
    required this.imagePath,
    this.isLocked = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Card(
          color: Colors.red[800],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
                  child: SvgPicture.asset(
                    imagePath,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Text(name, style: TextStyle(color: Colors.white)),
                    SizedBox(height: 4),
                    Icon(
                      Icons.play_circle,
                      color: isLocked ? Colors.grey : Colors.green,
                    ),
                    SizedBox(height: 4),
                    Text(progress, style: TextStyle(color: Colors.white)),
                    SizedBox(height: 4),
                    Text('OR', style: TextStyle(color: Colors.white)),
                    SizedBox(height: 4),
                    ElevatedButton(
                      onPressed: isLocked ? null : () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                        isLocked ? Colors.grey : Colors.green,
                      ),
                      child: Text(price),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        if (isLocked)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: Icon(Icons.lock, color: Colors.white, size: 40),
              ),
            ),
          ),
      ],
    );
  }
}
