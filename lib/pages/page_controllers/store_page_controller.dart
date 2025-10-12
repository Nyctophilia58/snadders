import '../../services/shared_prefs_service.dart';

class StorePageController {
  final SharedPrefsService _prefsService = SharedPrefsService();

  Future<int> loadCoins() async {
    return await _prefsService.loadCoins();
  }

  Future<int> loadDiamonds() async {
    return await _prefsService.loadDiamonds();
  }
}
