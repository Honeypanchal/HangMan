import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hangman/screens/game_screen.dart';
import 'package:flutter_hangman/screens/home_screen.dart';

import 'CateGoriesScreen.dart';

class WordscueLevelScreen extends StatefulWidget {
  const WordscueLevelScreen({Key? key}) : super(key: key);

  @override
  State<WordscueLevelScreen> createState() => _WordscueLevelScreenState();
}

class _WordscueLevelScreenState extends State<WordscueLevelScreen> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.png',
              fit: BoxFit.cover,
            ),
          ),

          SafeArea(
            child: Center(
              child: Column(
                children: [
                  SizedBox(height: 120),

                  // Title
                  Image.asset(
                    'assets/images/apptitle (2).png',
                    height: 100,
                  ),

                  SizedBox(height: 50),

                  // Black background behind buttons
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Black background image behind buttons
                      Image.asset(
                        'assets/images/Rectangle 78.png',
                        width: 300,
                        height: 350,
                        fit: BoxFit.fill,
                      ),

                      // Buttons column
                      Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              onTap: () async {
                                final uid = FirebaseAuth.instance.currentUser?.uid;
                                if (uid != null) {
                                  await FirebaseDatabase.instance.ref().child('users/$uid').update({
                                    'difficulty': 'beginner',
                                  });
                                }
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => GameScreen()));

                              };



                            },
                            child: Image.asset(
                              'assets/images/Beginner.png',
                              width: 250,
                              height: 62,
                              fit: BoxFit.fill,
                            ),
                          ),
                          SizedBox(height: 12),

                          GestureDetector(

                              onTap: () async {
                                final uid = FirebaseAuth.instance.currentUser?.uid;
                                if (uid != null) {
                                  await FirebaseDatabase.instance.ref().child('users/$uid').update({
                                    'difficulty': 'easy',
                                  });
                                }
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => GameScreen()),
                                );
                              },





                            child: Image.asset(
                              'assets/images/Easy.png',
                              width: 250,
                              height: 62,
                              fit: BoxFit.fill,
                            ),
                          ),
                          SizedBox(height: 12),

                          GestureDetector(
                            onTap: () {
                              onTap: () async {
                                final uid = FirebaseAuth.instance.currentUser?.uid;
                                if (uid != null) {
                                  await FirebaseDatabase.instance.ref().child('users/$uid').update({
                                    'difficulty': 'medium',
                                  });
                                }
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) =>GameScreen()),
                                );
                              };



                            },

                            child: Image.asset(
                              'assets/images/Medium.png',
                              width: 250,
                              height: 62,
                              fit: BoxFit.fill,
                            ),
                          ),
                          SizedBox(height: 12),

                          GestureDetector(
                            onTap: () {
                              onTap: () async {
                                final uid = FirebaseAuth.instance.currentUser?.uid;
                                if (uid != null) {
                                  await FirebaseDatabase.instance.ref().child('users/$uid').update({
                                    'difficulty': 'hard',
                                  });
                                }
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) =>GameScreen()),
                                );
                              };



                            },

                            child: Image.asset(
                              'assets/images/Expert.png',
                              width: 250,
                              height: 62,
                              fit: BoxFit.fill,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
