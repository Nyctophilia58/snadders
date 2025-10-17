import 'package:flutter/material.dart';
import 'package:snadders/services/iap_services.dart';
import '../../constants/board_constants.dart';
import '../../services/shared_prefs_service.dart';
import 'board_card.dart';

class BoardsTab extends StatefulWidget {
  final IAPService iapService;
  const BoardsTab({super.key, required this.iapService});

  @override
  State<BoardsTab> createState() => _BoardsTabState();
}

class _BoardsTabState extends State<BoardsTab> {
  final SharedPrefsService _prefsService = SharedPrefsService();
  List<bool> unlockedBoards = [];

  final String price = 'BDT 49.99';

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

  @override
  Widget build(BuildContext context) {
    if (unlockedBoards.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return GridView.count(
      crossAxisCount: 3,
      padding: const EdgeInsets.all(8.0),
      childAspectRatio: 0.75,
      children: List.generate(boardImages.length, (index) {
        return BoardCard(
          price: price,
          imagePath: boardImages[index],
          isLocked: !unlockedBoards[index],
          iapService: widget.iapService,
          productId: 'board_$index',
        );
      }),
    );
  }
}
