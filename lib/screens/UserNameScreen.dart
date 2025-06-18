import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hangman/screens/DashBoeard.dart';
import 'package:flutter_hangman/screens/home_screen.dart';

class Usernamescreen extends StatefulWidget {
  const Usernamescreen({super.key});

  @override
  State<Usernamescreen> createState() => _UsernamescreenState();
}

class _UsernamescreenState extends State<Usernamescreen> {
  final TextEditingController _controller = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  void _handlePlayButton() async {
    final username = _controller.text.trim();

    if (username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a nickname")),
      );
      return;
    }

    try {
      // Sign in anonymously
      final userCredential = await _auth.signInAnonymously();
      final userId = userCredential.user?.uid;

      // Store in Realtime Database
      await _dbRef.child('users').child(userId!).set({
        'userId': userId,
        'username': username,
        'difficulty': 'beginner', // default
        'category': 'general knowledge', // default
        'coins':0,
      });



      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User saved successfully!")),
      );

      Navigator.push(context, MaterialPageRoute(builder: (context)=>const Dashboard()));

      // TODO: Navigate to next screen here

    } catch (e) {
      print("🔥 Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/hangman_bg.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              top: 210,
              left: 0,
              right: 0,
              child: Image.asset('assets/images/wordscue.png'),
            ),
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    width: 319,
                    height: 62,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    alignment: Alignment.center,
                    child: TextField(
                      controller: _controller,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'NickName',
                        hintStyle: TextStyle(
                          color: Colors.black54,
                          fontWeight: FontWeight.w600,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 10),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),

            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding:  EdgeInsets.only(bottom: MediaQuery.of(context).
                size.height>900?335:MediaQuery.of(context).size.height>710?260:260),
                child: GestureDetector(
                  onTap: _handlePlayButton,
                  child: Image.asset('assets/images/play_button.png'),
                ),
              ),
            ),


          ],
        ),
      ),
    );
  }
}
