import 'dart:async';
import 'dart:ui';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();

  final AudioPlayer _bgPlayer = AudioPlayer();
  final AudioPlayer _soundEffectsPlayer = AudioPlayer();
  bool _isBgPlaying = false;
  double _soundEffectsVolume = 1.0;
  StreamSubscription? _sfxCompleteSubscription;
  bool _isMusicEnabled = true;

  static const platform = MethodChannel('com.ext.wordscue/audio');


  Future<void> init() async {
    // Inside AudioManager constructor or init method
    MethodChannel("com.ext.wordscue/audio").setMethodCallHandler((call) async {
      if (call.method == "pauseFromNative") {
        pauseBackgroundMusic(); // ✅ pause when screen is off
      }
    });

    await _bgPlayer.setReleaseMode(ReleaseMode.loop);

    await _bgPlayer.setSource(AssetSource('audio/BG_Hangman_Game.mp3'));
    print("🎵 AudioManager initialized: Background music ready");

    await _soundEffectsPlayer.setReleaseMode(ReleaseMode.release);
    print("🔊 AudioManager initialized: Sound effects player ready");
  }

  void setMusicEnabled(bool enabled) {
    _isMusicEnabled = enabled;
    if (!enabled && _isBgPlaying) {
      pauseBackgroundMusic();
    }
  }

  Future<void> playBackgroundMusic() async {
    if (_isMusicEnabled) {
      print("▶️ Playing BG music...");
      await _bgPlayer.setReleaseMode(ReleaseMode.loop);
      await _bgPlayer.play(AssetSource('audio/BG_Hangman_Game.mp3'));
      _isBgPlaying = true;
    }
  }


  Future<void> pauseBackgroundMusic() async {
    print("⏸️ Pausing BG music...");
    await _bgPlayer.pause();
    _isBgPlaying = false;
  }
  Future<void> requestAudioFocus() async {
    print("🧠 [AudioManager] Requesting audio focus via MethodChannel");
    try {
      await platform.invokeMethod('requestAudioFocus');
      print("✅ Audio focus requested");
    } catch (e) {
      print("❌ Could not request audio focus: $e");
    }
  }


  Future<void> abandonAudioFocus() async {
    try {
      await platform.invokeMethod('abandonAudioFocus');
    } catch (e) {
      print("⚠️ Error abandoning audio focus: $e");
    }
  }

  Future<void> stopBackgroundMusic() async {
    print("🛑 Stopping BG music...");
    await _bgPlayer.stop();
    _isBgPlaying = false;
  }

  Future<void> forceStopAllAudio() async {
    print("🛑 Forcing stop of all audio...");
    await _bgPlayer.stop();
    await _soundEffectsPlayer.stop();
    _isBgPlaying = false;
    try {
      await platform.invokeMethod('stopAudio');
    } catch (e) {
      print("Error invoking native stopAudio: $e");
    }
  }

  bool get isMusicPlaying => _isBgPlaying;

  Future<void> _playSoundEffect(String assetPath, VoidCallback onComplete) async {
    await pauseBackgroundMusic();
    await _soundEffectsPlayer.stop(); // Prevent overlapping
    await _soundEffectsPlayer.setVolume(_soundEffectsVolume);
    await _soundEffectsPlayer.play(AssetSource(assetPath));
    _listenOnceForSfxCompletion(onComplete);
  }

  void _listenOnceForSfxCompletion(VoidCallback onComplete) {
    _sfxCompleteSubscription?.cancel();
    _sfxCompleteSubscription = _soundEffectsPlayer.onPlayerComplete.listen((event) async {
      if (_isMusicEnabled) {
        await playBackgroundMusic();
      }
      _sfxCompleteSubscription?.cancel();
      onComplete();
    });
  }

  Future<void> playloseSound() async {
    await _playSoundEffect('audio/lose game.mp3', () {
      print("✅ lose sound done. Resuming BG...");
    });
  }

  Future<void> playwinSound() async {
    await _playSoundEffect('audio/success.mp3', () {
      print("✅ win sound done. Resuming BG...");
    });
  }

  Future<void> playbuttonSound() async {
    await _playSoundEffect('audio/tap on button.mp3', () {
      print("✅ button sound done. Resuming BG...");
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

  Future<void> dispose() async {
    print("🧹 Disposing AudioManager...");
    await _sfxCompleteSubscription?.cancel();
    await forceStopAllAudio();
    await _bgPlayer.dispose();
    await _soundEffectsPlayer.dispose();
  }
}