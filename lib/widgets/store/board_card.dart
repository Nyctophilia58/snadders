import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class BoardCard extends StatelessWidget {
  final String price;
  final String imagePath;
  final bool isLocked;

  const BoardCard({
    super.key,
    required this.price,
    required this.imagePath,
    required this.isLocked,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Card(
          color: Colors.grey[800],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: SvgPicture.asset(
                    imagePath,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
              Padding(
                padding: isLocked ? EdgeInsets.all(8.0) : EdgeInsets.all(0.0),
                child: Column(
                  children: [
                    if (isLocked)
                      ElevatedButton(
                        onPressed: !isLocked ? null : () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Purchased for $price')),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        child: Text(isLocked ? price : ''),
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
              color: Colors.black.withOpacity(0.3),
              child: Center(
                child: Icon(Icons.lock, color: Colors.white, size: 40),
              ),
            ),
          ),
      ],
    );
  }
}
