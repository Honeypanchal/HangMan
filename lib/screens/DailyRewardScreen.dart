import 'package:flutter/material.dart';
import 'package:flutter_hangman/screens/DashBoeard.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class DailyRewardPage extends StatefulWidget {
  @override
  _DailyRewardPageState createState() => _DailyRewardPageState();
}

class _DailyRewardPageState extends State<DailyRewardPage> {
  int currentDay = 1;
  late SharedPreferences prefs;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final String? currentUserEmail = FirebaseAuth.instance.currentUser?.email;

  @override
  void initState() {
    super.initState();
    initRewards();
  }

  Future<void> initRewards() async {
    prefs = await SharedPreferences.getInstance();
    DateTime now = DateTime.now();
    String? lastClaim = prefs.getString('lastClaimedDate');
    int day = prefs.getInt('currentDay') ?? 1;

    bool isNewClaim = false;

    if (lastClaim != null) {
      DateTime lastClaimedDate = DateTime.parse(lastClaim);
      if (now.difference(lastClaimedDate).inHours >= 24) {
        day = (day + 1).clamp(1, 7);
        await prefs.setString('lastClaimedDate', now.toIso8601String());
        await prefs.setInt('currentDay', day);
        isNewClaim = true;
      }
    } else {
      await prefs.setString('lastClaimedDate', now.toIso8601String());
      await prefs.setInt('currentDay', day);
      isNewClaim = true;
    }

    setState(() {
      currentDay = day;
    });

    if (isNewClaim) {
      await addRewardToUser();
      // Dialog is now triggered on tap, so no call here
    }
  }

  Future<void> addRewardToUser() async {
    if (currentUserEmail == null) return;

    try {
      DatabaseReference usersRef = _database.child('users');
      DataSnapshot snapshot = await usersRef.get();

      if (snapshot.exists) {
        Map<dynamic, dynamic> usersMap = snapshot.value as Map<dynamic, dynamic>;

        String? userKey;
        usersMap.forEach((key, value) {
          if (value['email'] == currentUserEmail) {
            userKey = key;
          }
        });

        if (userKey != null) {
          int currentCoins = usersMap[userKey]['coins'] ?? 0;
          await usersRef.child(userKey!).update({'coins': currentCoins + 10});
        }
      }
    } catch (e) {
      print('Error adding reward: $e');
    }
  }

  void showCongratulationDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              Container(
                //margin: const EdgeInsets.symmetric(horizontal: 20),
                //padding: const EdgeInsets.symmetric(horizontal: 30),
                decoration: const BoxDecoration(
                  color: Color.fromRGBO(97, 49, 12, 0.9),
                ),
                height: 390,
                width: MediaQuery.of(context).size.width > 350
                    ? 373
                    : MediaQuery.of(context).size.width > 400
                    ? 353
                    : 360,
                child: Center(
                  child: Image.asset(
                    'assets/images/Group 107.png',
                    height: 281,
                    width: 260,
                  ),
                ),
              ),
              Positioned(
                top: 1,
                right: 1,
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Image.asset(
                    'assets/images/Group (4).png',
                    width: 40,
                    height: 40,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildRewardItem(int index) {
    int day = index + 1;
    bool isCollected = day < currentDay;
    bool isToday = day == currentDay;
    bool isLocked = day > currentDay;

    bool isDay7 = day == 7;
    double boxWidth = isDay7 ? 309 : 90;
    double boxHeight = isDay7 ? 108 : 110;

    Widget rewardContent = SizedBox(
      width: boxWidth,
      height: boxHeight,
      child: Stack(
        children: [
          if (isDay7)
            Positioned.fill(


            child:
        Image.asset('assets/images/container_day7.png',
        height: 160,
        fit: BoxFit.fill,)



            )
          else
            Positioned.fill(
              child: Image.asset(
                'assets/images/level_x5F_1.png',
                height: 50,
                fit: BoxFit.fill,
              ),
            ),

          if (isDay7)
            Positioned(
              left: 10,
              top: 10,
              child: Image.asset(
                'assets/images/Group (7).png', // Placeholder for pot_of_gold.png
                width: 90,
                height: 82,
              ),
            ),
          if (isDay7)
            Container(
              padding: EdgeInsets.only(right: 70),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        day.toString().padLeft(2, '0'),
                        style: const TextStyle(
                          fontSize: 40,
                          color: Color.fromRGBO(46, 46, 46, 1),
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Fredoka',
                        ),
                      ),
                      SizedBox(width: 5,),
                      Text(
                        'DAY',
                        style: const TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w600,
                          color: Color.fromRGBO(46, 46, 46, 1),
                          fontFamily: 'Fredoka',
                        ),
                      ),
                    ],
                  ),
                  if (isLocked)
                    const   Text(


                      'UNLOCK',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w600,
                        color: Color.fromRGBO(46, 46, 46, 1),
                        fontFamily: 'Fredoka',
                      ),
                    )
                  else if (!isLocked || isToday)
                      const Text(
                        'COLLECTED',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Color.fromRGBO(46, 46, 46, 1),
                          fontFamily: 'Fredoka',
                        ),
                      ),


                ],
              ),
            )
          else
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    day.toString().padLeft(2, '0'),
                    style: const TextStyle(
                      fontSize: 40,
                      color: Color.fromRGBO(46, 46, 46, 1),
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Fredoka',
                    ),
                  ),
                  Text(
                    'DAY',
                    style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w600,
                      color: Color.fromRGBO(46, 46, 46, 1),
                      fontFamily: 'Fredoka',
                    ),
                  ),
                  if (isCollected)
                    const Text(
                      'COLLECTED',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Color.fromRGBO(46, 46, 46, 1),
                        fontFamily: 'Fredoka',
                      ),
                    )
                  else if (isLocked)
                    const Text(
                      'UNLOCK',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Color.fromRGBO(46, 46, 46, 1),
                        fontFamily: 'Fredoka',
                      ),
                    ),
                ],
              ),
            ),
          if (isDay7 && isLocked)
            Positioned(
              right: 6,
              bottom: -10,
              child: Image.asset(
                'assets/images/LOCK (2).png',

                width: 50,
              ),
            )
          else if (isDay7 && (isCollected || isToday))
            Positioned(
              right: 10,
              top: 10,
              child: Image.asset(
                'assets/images/Group (7).png',
                width: 30,
                height: 30,
              ),
            ),
          if (!isDay7 && (isCollected || isToday))
            Positioned(
              bottom: 7,
              right: 6,
              child: Image.asset(
                'assets/images/goldbg.png',
              width: 40,
              ),
            )
          else if (!isDay7 && isLocked)
            Positioned(
              bottom: 0,
              right: -2,
              child: Image.asset(
                'assets/images/LOCK (2).png',
                width: 32,
              ),
            ),
        ],
      ),
    );

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isDay7 ? 0 : 6),
      child: isToday
          ? GestureDetector(
        onTap: () {
          showCongratulationDialog();
        },
        child: rewardContent,
      )
          : rewardContent,
    );
  }

  @override
  Widget build(BuildContext context) {
    double brownBoxWidth = MediaQuery.of(context).size.width;


    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            'assets/images/background.png',
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
          ),
          Align(
            alignment: Alignment.center,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              margin:  EdgeInsets.symmetric(horizontal: MediaQuery.of(context).
              size.width>400?20:MediaQuery.of(context).size.width>360?10:10,),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    height: 400,
                    width: brownBoxWidth,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Color.fromRGBO(97, 49, 12, 0.9),


                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(3, (i) => Padding(
                          padding: const EdgeInsets.all(0.0),
                          child: buildRewardItem(i),
                        )),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(3, (i) => Padding(
                          padding: const EdgeInsets.all(0.0),
                          child: buildRewardItem(i + 3),
                        )),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5.0),
                            child: buildRewardItem(6), // Day 7
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height>900?224:MediaQuery.of(context).size.height>700?140:200,
            right: 15,
            child: GestureDetector(
              onTap: () {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => const Dashboard()));
              },
              child: Image.asset('assets/images/close_icon.png'),
            ),
          ),
        ],
      ),
    );
  }
}