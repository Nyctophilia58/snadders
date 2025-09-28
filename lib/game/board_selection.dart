import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BoardSelector extends StatefulWidget {
  const BoardSelector({super.key});

  @override
  State<BoardSelector> createState() => _BoardSelectorState();
}

class _BoardSelectorState extends State<BoardSelector> {
  int currentBoardIndex = 0;

  final List<String> boardImages = [
    'assets/images/boards/1.svg',
    'assets/images/boards/2.svg',
    'assets/images/boards/3.svg',
  ];

  void nextBoard() => setState(() => currentBoardIndex = (currentBoardIndex + 1) % boardImages.length);
  void prevBoard() => setState(() => currentBoardIndex = (currentBoardIndex - 1 + boardImages.length) % boardImages.length);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        height: 600,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Center(
                child: SvgPicture.asset(
                  boardImages[currentBoardIndex],
                  fit: BoxFit.contain,
                  width: 360,
                  height: 500,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(icon: const Icon(Icons.arrow_left, size: 40), onPressed: prevBoard),
                Text('Board ${currentBoardIndex + 1}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(Icons.arrow_right, size: 40), onPressed: nextBoard),
              ],
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Select', style: TextStyle(fontSize: 18, color: Colors.white)),
              onPressed: () => Navigator.pop(context, currentBoardIndex), // RETURN THE INDEX
            ),
          ],
        ),
      ),
    );
  }
}
