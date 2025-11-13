import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snadders/services/shared_prefs_service.dart';

final boardProvider = StateNotifierProvider<BoardNotifier, int>((ref) {
  return BoardNotifier()..loadBoard();
});

class BoardNotifier extends StateNotifier<int> {
  BoardNotifier() : super(0);

  final SharedPrefsService _prefs = SharedPrefsService();

  Future<void> loadBoard() async {
    final saved = await _prefs.getSelectedBoard();
    state = saved ?? 0;
  }

  Future<void> selectBoard(int board) async {
    state = board;
    await _prefs.saveSelectedBoard(board);
  }
}
