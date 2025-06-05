
import 'package:flutter/material.dart';
import 'package:flutter_hangman/screens/UserNameScreen.dart';
import 'package:flutter_hangman/screens/home_screen.dart';



class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  @override
  @override
  void initState() {
    super.initState();

    // Initialize and play background music without using `await` here
    // AudioManager().init().then((_) {
    //   AudioManager().playBackgroundMusic();
    // }
    // )
    // ;

    // Navigate to Homepage after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Usernamescreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(image: DecorationImage(image: AssetImage("assets/images/Hangman Game.png"),
          fit: BoxFit.cover)),
    ),);
  }
}
