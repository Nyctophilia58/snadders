import 'package:flutter/material.dart';

import 'board_card.dart';

class BoardsTab extends StatelessWidget {
  const BoardsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      padding: EdgeInsets.all(8.0),
      children: [
        BoardCard(name: 'Nature', progress: '0/49', price: 'BDT 259.69'),
        BoardCard(name: 'Egypt', progress: '0/149', price: 'BDT 259.69'),
        BoardCard(name: 'Disco', progress: '0/99', price: 'BDT 259.69'),
        BoardCard(name: 'Marble', progress: '0/99', price: 'BDT 259.69'),
        BoardCard(name: 'Candy', progress: '0/99', price: 'BDT 259.69'),
        BoardCard(name: 'Penguin', progress: '0/99', price: 'BDT 259.69'),
      ],
    );
  }
}
