import 'package:flutter/material.dart';
import 'package:flutter_hangman/screens/Splash_Screen2.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/foundation.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _videoController;

  @override
  void initState() {
    super.initState();

    _videoController = kIsWeb
        ? VideoPlayerController.networkUrl(
        Uri.parse('assets/audio/Splash_screen.mp4')) // For web
        : VideoPlayerController.asset(
        'assets/audio/Splash_screen.mp4'); // For mobile

    _videoController.initialize().then((_) {
      setState(() {});
      _videoController.play();

      _videoController.addListener(() {
        if (_videoController.value.position >=
            _videoController.value.duration &&
            !_videoController.value.isPlaying) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => StartScreen()),
          );
        }
      });
    });
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder(
        future: _videoController.initialize(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            _videoController.play();
            return AspectRatio(
              aspectRatio: _videoController.value.aspectRatio,
              child: VideoPlayer(_videoController),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}