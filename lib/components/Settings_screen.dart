import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hangman/screens/DashBoeard.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isMusicOn = true;
  bool isTimerOn = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final snapshot = await FirebaseDatabase.instance
            .ref('users/${user.uid}/settings')
            .get();
        final data = snapshot.value as Map<dynamic, dynamic>?;
        setState(() {
          isTimerOn = data?['timerOn'] as bool? ?? false;
          isMusicOn = data?['musicOn'] as bool? ?? true;
        });
      } catch (e) {
        print("DEBUG: Error loading settings: $e");
      }
    }
  }

  Future<void> _saveSettings(String key, bool value) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseDatabase.instance
            .ref('users/${user.uid}/settings')
            .update({key: value});
        print("DEBUG: Saved $key: $value");
      } catch (e) {
        print("DEBUG: Error saving settings: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/hangman_bg.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                width: 345,
                height: 282,
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(97, 49, 12, 0.9),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 25),
                    const Text(
                      'SETTINGS',
                      style: TextStyle(
                        fontFamily: 'Fredoka',
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(226, 187, 69, 1),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: 300,
                      height: 160,
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(254, 204, 92, 1),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Image.asset('assets/images/music_icon.png'),
                                  const SizedBox(width: 10),
                                  const Text(
                                    'Music',
                                    style: TextStyle(
                                      fontSize: 26,
                                      fontFamily: 'Fredoka',
                                      fontWeight: FontWeight.w600,
                                      color: Color.fromRGBO(97, 49, 12, 1),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                width: 70,
                                height: 30,
                                child: Transform.scale(
                                  scale: 0.8,
                                  child: Switch(
                                    value: isMusicOn,
                                    onChanged: (val) {
                                      setState(() {
                                        isMusicOn = val;
                                      });
                                      _saveSettings('musicOn', val);
                                    },
                                    activeColor: Colors.white,
                                    activeTrackColor: const Color.fromRGBO(194, 97, 0, 1),
                                    inactiveThumbColor: Colors.white,
                                    inactiveTrackColor: Colors.white54,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Image.asset('assets/images/timer_icon.png'),
                                  const SizedBox(width: 10),
                                  const Text(
                                    'Timer',
                                    style: TextStyle(
                                      fontSize: 26,
                                      fontFamily: 'Fredoka',
                                      fontWeight: FontWeight.w600,
                                      color: Color.fromRGBO(97, 49, 12, 1),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                width: 70,
                                height: 30,
                                child: Transform.scale(
                                  scale: 0.8,
                                  child: Switch(
                                    value: isTimerOn,
                                    onChanged: (val) {
                                      setState(() {
                                        isTimerOn = val;
                                      });
                                      _saveSettings('timerOn', val);
                                    },
                                    activeColor: Colors.white,
                                    activeTrackColor: const Color.fromRGBO(194, 97, 0, 1),
                                    inactiveThumbColor: Colors.white,
                                    inactiveTrackColor: Colors.white54,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: -15,
                right: 5,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Dashboard()));
                  },
                  child: Image.asset('assets/images/close_icon.png'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}