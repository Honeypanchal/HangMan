import 'package:audioplayers/audioplayers.dart';

class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();

  final AudioPlayer _bgPlayer = AudioPlayer();
  final AudioPlayer _soundEffectsPlayer = AudioPlayer();
  bool _isBgPlaying = false;
  double _soundEffectsVolume = 1.0;

  Future<void> init() async {
    await _bgPlayer.setReleaseMode(ReleaseMode.loop);
    await _bgPlayer.setSource(AssetSource('audio/BG Hangman Game.mp3'));
    print("🎵 AudioManager initialized: Background music ready");

    await _soundEffectsPlayer.setReleaseMode(ReleaseMode.release);
    print("🔊 AudioManager initialized: Sound effects player ready");
  }

  Future<void> playBackgroundMusic() async {
    if (!_isBgPlaying) {
      print("▶️ Playing BG music...");
      await _bgPlayer.resume();
      _isBgPlaying = true;
    }
  }

  Future<void> pauseBackgroundMusic() async {
    print("⏸️ Pausing BG music...");
    await _bgPlayer.pause();
    _isBgPlaying = false;
  }

  Future<void> stopBackgroundMusic() async {
    print("🛑 Stopping BG music...");
    await _bgPlayer.stop();
    _isBgPlaying = false;
  }

  Future<void> playloseSound() async {
    await pauseBackgroundMusic();
    print(" Playing LOSE sound with volume: $_soundEffectsVolume...");
    await _soundEffectsPlayer.setVolume(_soundEffectsVolume);
    await _soundEffectsPlayer.play(
      AssetSource('audio/lose game.mp3'),
    );

    _soundEffectsPlayer.onPlayerComplete.listen((event) async {
      print("✅ lose sound done. Resuming BG...");
      await playBackgroundMusic();
    });
  }
  Future<void> playwinSound() async {
    await pauseBackgroundMusic();
    print("🔪 Playing win sound with volume: $_soundEffectsVolume...");
    await _soundEffectsPlayer.setVolume(_soundEffectsVolume);
    await _soundEffectsPlayer.play(
      AssetSource('audio/success.mp3'),
    );

    _soundEffectsPlayer.onPlayerComplete.listen((event) async {
      print("✅ win sound done. Resuming BG...");
      await playBackgroundMusic();
    });
  }
  Future<void> playbuttonSound() async {
    await pauseBackgroundMusic();
    print(" Playing button sound with volume: $_soundEffectsVolume...");
    await _soundEffectsPlayer.setVolume(_soundEffectsVolume);
    await _soundEffectsPlayer.play(
      AssetSource('audio/tap on button.mp3'),
    );

    _soundEffectsPlayer.onPlayerComplete.listen((event) async {
      print("✅ play button sound done. Resuming BG...");
      await playBackgroundMusic();
    });
  }



  Future<void> setMusicVolume(double value) async {
    print("🎵 Setting background music volume to: $value");
    await _bgPlayer.setVolume(value);
  }

  Future<void> setSoundEffectsVolume(double value) async {
    print("🔊 Setting sound effects volume to: $value");
    _soundEffectsVolume = value;
    await _soundEffectsPlayer.setVolume(value);
  }
}
