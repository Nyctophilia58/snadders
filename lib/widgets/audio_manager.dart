import 'package:audioplayers/audioplayers.dart';

class AudioManager {
  AudioManager._privateConstructor();
  static final AudioManager instance = AudioManager._privateConstructor();

  bool _enabled = true;
  bool get enabled => _enabled;

  final AudioPlayer _bgmPlayer = AudioPlayer();

  void setEnabled(bool value) {
    _enabled = value;

    if (!_enabled) {
      _bgmPlayer.pause();
      // optionally stop all SFX if needed
    }
  }

  // Background music
  Future<void> playBGM(String filename, {bool loop = true}) async {
    if (!_enabled) return;

    _bgmPlayer.setReleaseMode(loop ? ReleaseMode.loop : ReleaseMode.release);
    await _bgmPlayer.play(AssetSource(filename));
  }

  Future<void> stopBGM() async {
    await _bgmPlayer.stop();
  }

  // Sound effects (one-shots)
  Future<void> playSFX(String filename) async {
    if (!_enabled) return;
    // Each SFX gets its own AudioPlayer
    AudioPlayer player = AudioPlayer();
    await player.play(AssetSource(filename));
  }
}
