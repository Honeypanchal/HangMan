import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hangman/components/CreateGameScreen.dart';
import 'package:flutter_hangman/components/Settings_screen.dart';
import 'package:flutter_hangman/screens/CateGoriesScreen.dart';
import 'package:flutter_hangman/screens/LeaderBoard.dart';
import 'package:flutter_hangman/screens/LevalScreen.dart';

import '../components/AudioManager.dart';
import 'DailyRewardScreen.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboeardState();
}

class _DashboeardState extends State<Dashboard> with WidgetsBindingObserver {
  final AudioPlayer _bgPlayer = AudioPlayer();
  bool isPlaying =false;
  void PlayClickSound()
  {
    AudioManager().playbuttonSound();
  }
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _playMusic();
  }

  void _playMusic() async {
    await _bgPlayer.setReleaseMode(ReleaseMode.loop);
    await _bgPlayer.play(AssetSource('audio/BG_Hangman_Game.mp3'));
    isPlaying = true;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _bgPlayer.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      // App backgrounded or locked
      _bgPlayer.pause();
    } else if (state == AppLifecycleState.resumed) {
      // App foregrounded again
      if (!isPlaying) {
        _playMusic();
      } else {
        _bgPlayer.resume();
      }
    }
  }


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

              SizedBox(height:MediaQuery.of(context).size.height>900?80: 50),


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
                          PlayClickSound();
                          Navigator.push(context, MaterialPageRoute(builder: (context) => WordscueLevelScreen()));
                        },

                        child: Image.asset('assets/images/play_button.png', height: 60),
                      ),
                      const SizedBox(height: 15),
                      GestureDetector(
                        onTap: () {
                          PlayClickSound();
                          Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsScreen()));
                        },
                        child: Image.asset('assets/images/Settings.png', height: 60),
                      ),
                      const SizedBox(height: 15),
                      GestureDetector(
                        onTap: () {
                          PlayClickSound();
                          Navigator.push(context, MaterialPageRoute(builder: (context) => LeaderBoard()));
                        },
                        child: Image.asset('assets/images/Leader_Board.png', height: 60),
                      ),
                      const SizedBox(height: 15),
                      GestureDetector(
                        onTap: () {
                          PlayClickSound();
                          Navigator.push(context, MaterialPageRoute(builder: (context) => DailyRewardPage()));
                        },
                        child: Image.asset('assets/images/Daily_Reward.png', height: 60),
                      ),
                      const SizedBox(height: 15),
                      GestureDetector(
                        onTap: () {
                          PlayClickSound();
                          Navigator.push(context, MaterialPageRoute(builder: (context) => CategoriesScreen()));
                        },
                        child: Image.asset('assets/images/Catagories.png', height: 60),
                      ),
                      // ElevatedButton(onPressed: (){
                      //   Navigator.push(context, MaterialPageRoute(builder: (context)=>CreateGameScreen()));
                      // }, child: Text("store data")),
                      //   SizedBox(height: 10,),
                      // ElevatedButton(onPressed: (){
                      //   Navigator.push(context,
                      //       MaterialPageRoute(builder: (context)=>JoinGameScreen()));
                      // }, child: Text("invite link"))
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
