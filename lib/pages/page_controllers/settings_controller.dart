class SettingsController {
  bool soundEnabled = true;
  String selectedLanguage = 'English';
  String selectedBoard = 'Classic';

  final List<String> boardThemes = ['Classic', 'Ocean', 'Forest', 'Candy'];
  final List<String> languages = ['English', 'Bangla'];

  void toggleSound(bool value) {
    soundEnabled = value;
  }

  void selectLanguage(String language) {
    selectedLanguage = language;
  }

  void selectBoard(String board) {
    selectedBoard = board;
  }

  void openStore() {}
  void openNotifications() {}
  void troubleshoot() {}
  void requestAccountDeletion() {}
  void rateUs() {}
  void shareApp() {}
}
