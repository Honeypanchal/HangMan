import 'package:flutter/material.dart';
import 'package:flutter_hangman/screens/Splash_Screen2.dart';
import 'package:video_player/video_player.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _controller;
  bool _navigated = false; // ✅ Add this line

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.asset("assets/audio/Splash_screen.mp4")
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
      });

    _controller.setLooping(false);
    _controller.setVolume(1.0);

    _controller.addListener(() {
      if (!_navigated && _controller.value.position >= _controller.value.duration) {
        _navigated = true;

        // ✅ Initialize HomeController to trigger background music


        Future.delayed(Duration(milliseconds: 200), () {
          Navigator.push(context, MaterialPageRoute(builder: (context)=>StartScreen()));        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _controller.value.isInitialized
          ? FittedBox(
        fit: BoxFit.fill,
        child: SizedBox(
          width: _controller.value.size.width,
          height: _controller.value.size.height,
          child: VideoPlayer(_controller),
        ),
      )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}

