import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isMusicOn = true;
  bool isTimerOn = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // background as in image
      body:
        Container(
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
              // Main Container
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
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
                      margin: EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(254, 204, 92, 1),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Music Row
                          // Music Row
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
                                    value: isMusicOn, // ✅ Fixed here
                                    onChanged: (val) {
                                      setState(() {
                                        isMusicOn = val;
                                      });
                                    },
                                    activeColor: Colors.white,
                                    activeTrackColor: Color.fromRGBO(194, 97, 0, 1),
                                    inactiveThumbColor: Colors.white,
                                    inactiveTrackColor: Colors.white54,
                                  ),
                                ),
                              ),
                            ],
                          ),

// Timer Row
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
                                    value: isTimerOn, // ✅ Correct
                                    onChanged: (val) {
                                      setState(() {
                                        isTimerOn = val;
                                      });
                                    },
                                    activeColor: Colors.white,
                                    activeTrackColor: Color.fromRGBO(194, 97, 0, 1),
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
              // Close Button
              Positioned(
                top: -15,
                right: 5,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child:
                  Image.asset('assets/images/close_icon.png'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
