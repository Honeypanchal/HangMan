import 'package:flutter/material.dart';
import 'package:flutter_hangman/components/Settings_screen.dart';
import 'package:flutter_hangman/screens/CateGoriesScreen.dart';
import 'package:flutter_hangman/screens/LeaderBoard.dart';
import 'package:flutter_hangman/screens/LevalScreen.dart';

import 'DailyRewardScreen.dart';

class Dashboeard extends StatefulWidget {
  const Dashboeard({super.key});

  @override
  State<Dashboeard> createState() => _DashboeardState();
}

class _DashboeardState extends State<Dashboeard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/hangman_bg.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.17),
                child: Image.asset(
                  'assets/images/wordscue.png',

                ),
              ),

              // wordscue image at top center


              const SizedBox(height: 50),

              // Main frosted container
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 20,horizontal: 10),
                  width: 330,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.35),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => WordscueLevelScreen()));
                        },
                        child: Image.asset('assets/images/play_button.png', height: 60),
                      ),
                      const SizedBox(height: 15),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsScreen()));
                        },
                        child: Image.asset('assets/images/Settings.png', height: 60),
                      ),
                      const SizedBox(height: 15),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => LeaderBoard()));
                        },
                        child: Image.asset('assets/images/Leader_Board.png', height: 60),
                      ),
                      const SizedBox(height: 15),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => DailyRewardPage()));
                        },
                        child: Image.asset('assets/images/Daily_Reward.png', height: 60),
                      ),
                      const SizedBox(height: 15),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => CategoriesScreen()));
                        },
                        child: Image.asset('assets/images/Catagories.png', height: 60),
                      ),
                    ],
                  ),

                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
