import 'package:audioplayers/audioplayers.dart';
import 'package:snadders/services/shared_prefs_service.dart';

class AudioManager {
  static final AudioManager instance = AudioManager._internal();

  bool enabled = true;
  AudioManager._internal();

  Future<void> init() async {
    final prefs = SharedPrefsService();
    enabled = await prefs.getSoundEnabled() ?? true;
  }

  void setEnabled(bool value) {
    enabled = value;
    SharedPrefsService().saveSoundEnabled(value);
  }

  Future<void> playSFX(String filename) async {
    if (!enabled) return;
    final player = AudioPlayer();
    await player.play(AssetSource(filename));
  }
}
