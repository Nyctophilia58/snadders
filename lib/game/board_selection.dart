import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants/board_constants.dart';
import '../pages/store_page.dart';
import '../services/shared_prefs_service.dart';

class BoardSelector extends StatefulWidget {
  const BoardSelector({super.key});

  @override
  State<BoardSelector> createState() => _BoardSelectorState();
}

class _BoardSelectorState extends State<BoardSelector> {
  int currentBoardIndex = 0;
  List<bool> unlockedBoards = [];
  final SharedPrefsService _prefsService = SharedPrefsService();

  @override
  void initState() {
    super.initState();
    _loadUnlockedBoards();
  }

  Future<void> _loadUnlockedBoards() async {
    List<bool> boards = List.generate(
      boardImages.length,
          (index) => index < defaultUnlockedBoards,
    );

    for (int i = 0; i < boardImages.length; i++) {
      boards[i] = await _prefsService.loadBoardUnlocked(i) || boards[i];
    }

    setState(() {
      unlockedBoards = boards;
    });
  }

  void nextBoard() => setState(() => currentBoardIndex = (currentBoardIndex + 1) % boardImages.length);
  void prevBoard() => setState(() => currentBoardIndex = (currentBoardIndex - 1 + boardImages.length) % boardImages.length);

  @override
  Widget build(BuildContext context) {
    if (unlockedBoards.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    bool isUnlocked = unlockedBoards[currentBoardIndex];

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
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SvgPicture.asset(
                      boardImages[currentBoardIndex],
                      fit: BoxFit.contain,
                      width: 360,
                      height: 500,
                    ),
                    if (!isUnlocked)
                      FittedBox(
                        fit: BoxFit.contain,
                        child: Container(
                          width: 360,
                          height: 500,
                          color: Colors.black.withOpacity(0.3),
                          child: const Center(
                            child: Icon(Icons.lock, color: Colors.white, size: 80),
                          ),
                        ),
                      ),
                  ],
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
              onPressed: () {
                if (isUnlocked) {
                  Navigator.pop(context, currentBoardIndex);
                } else {
                  Navigator.pop(context);

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => StorePage(initialTabIndex: 2),
                    ),
                  );
                }
              },
              child: Text(isUnlocked ? 'Select' : 'Buy',
                  style: const TextStyle(fontSize: 18, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
