import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_hangman/screens/UserNameScreen.dart';
import 'package:flutter_hangman/screens/DashBoeard.dart';

import '../components/AudioManager.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen>  with WidgetsBindingObserver   {
  final audioManager = AudioManager();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    audioManager.init().then((_) {
      audioManager.playBackgroundMusic();
    });
    // Wait 2 seconds and then decide which screen to go to
    Future.delayed(const Duration(seconds: 2), () {
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        // User already signed in → Go to Dashboard
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Dashboeard()),
        );
      } else {
        // User not signed in → Go to Username Screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Usernamescreen()),
        );
      }
    });
  }


  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    audioManager.stopBackgroundMusic();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      audioManager.pauseBackgroundMusic(); // Pause when leaving
    } else if (state == AppLifecycleState.resumed) {
      audioManager.playBackgroundMusic(); // Resume when returning
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/Hangman Game.png"),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
