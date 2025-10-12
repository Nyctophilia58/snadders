import '../../constants/board_constants.dart';
import '../../services/shared_prefs_service.dart';

class BoardSelectorController {
  int currentBoardIndex = 0;
  final SharedPrefsService _prefsService = SharedPrefsService();

  Future<List<bool>> loadUnlockedBoards() async {
    List<bool> boards = List.generate(
      boardImages.length,
          (index) => index < defaultUnlockedBoards,
    );

    for (int i = 0; i < boardImages.length; i++) {
      boards[i] = await _prefsService.loadBoardUnlocked(i) || boards[i];
    }

    return boards;
  }

  void nextBoard() {
    currentBoardIndex = (currentBoardIndex + 1) % boardImages.length;
  }

  void prevBoard() {
    currentBoardIndex = (currentBoardIndex - 1 + boardImages.length) % boardImages.length;
  }
}
