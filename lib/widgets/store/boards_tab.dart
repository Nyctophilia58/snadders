import 'package:flutter/material.dart';
import 'board_card.dart';

class BoardsTab extends StatelessWidget {
  const BoardsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      padding: EdgeInsets.all(8.0),
      childAspectRatio: 0.75,
      children: [
        BoardCard(
          name: 'Nature',
          progress: '0/49',
          price: 'BDT 259.69',
          imagePath: 'assets/images/boards/1.svg',
          isLocked: false,
        ),
        BoardCard(
          name: 'Egypt',
          progress: '0/149',
          price: 'BDT 259.69',
          imagePath: 'assets/images/boards/2.svg',
          isLocked: false,
        ),
        BoardCard(
          name: 'Disco',
          progress: '0/99',
          price: 'BDT 259.69',
          imagePath: 'assets/images/boards/3.svg',
          isLocked: false,
        ),
        BoardCard(
          name: 'Marble',
          progress: '0/99',
          price: 'BDT 259.69',
          imagePath: 'assets/images/boards/4.svg',
          isLocked: true,
        ),
        BoardCard(
          name: 'Candy',
          progress: '0/99',
          price: 'BDT 259.69',
          imagePath: 'assets/images/boards/5.svg',
          isLocked: true,
        ),
        BoardCard(
          name: 'Penguin',
          progress: '0/99',
          price: 'BDT 259.69',
          imagePath: 'assets/images/boards/6.svg',
          isLocked: true,
        ),
      ],
    );
  }
}
