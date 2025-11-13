import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snadders/services/shared_prefs_service.dart';

final audioProvider = StateNotifierProvider<AudioNotifier, bool>((ref) {
  final notifier = AudioNotifier();
  notifier.loadAudioState();
  return notifier;
});

class AudioNotifier extends StateNotifier<bool> {
  final SharedPrefsService _prefsService = SharedPrefsService();

  AudioNotifier() : super(true);

  Future<void> loadAudioState() async {
    final saved = await _prefsService.getSoundEnabled();
    state = saved ?? true;
  }

  Future<void> toggleAudio(bool value) async {
    state = value;
    await _prefsService.saveSoundEnabled(value);
  }
}
