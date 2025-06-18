
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';
//
// class DailyRewardPage extends StatefulWidget {
//   @override
//   _DailyRewardPageState createState() => _DailyRewardPageState();
// }
//
// class _DailyRewardPageState extends State<DailyRewardPage> {
//   int currentDay = 1;
//   late SharedPreferences prefs;
//   final DatabaseReference _database = FirebaseDatabase.instance.ref();
//   final String? currentUserEmail = FirebaseAuth.instance.currentUser?.email;
//
//   @override
//   void initState() {
//     super.initState();
//     initRewards();
//   }
//
//   Future<void> initRewards() async {
//     prefs = await SharedPreferences.getInstance();
//     DateTime now = DateTime.now();
//     String? lastClaim = prefs.getString('lastClaimedDate');
//     int day = prefs.getInt('currentDay') ?? 1;
//
//     bool isNewClaim = false;
//
//     if (lastClaim != null) {
//       DateTime lastClaimedDate = DateTime.parse(lastClaim);
//       if (now.difference(lastClaimedDate).inHours >= 24) {
//         day = (day + 1).clamp(1, 7);
//         await prefs.setString('lastClaimedDate', now.toIso8601String());
//         await prefs.setInt('currentDay', day);
//         isNewClaim = true;
//       }
//     } else {
//       await prefs.setString('lastClaimedDate', now.toIso8601String());
//       await prefs.setInt('currentDay', day);
//       isNewClaim = true;
//     }
//
//     setState(() {
//       currentDay = day;
//     });
//
//     if (isNewClaim) {
//       await addRewardToUser();
//       showCongratulationDialog();
//     }
//   }
//
//   Future<void> addRewardToUser() async {
//     if (currentUserEmail == null) return;
//
//     try {
//       DatabaseReference usersRef = _database.child('users');
//       DataSnapshot snapshot = await usersRef.get();
//
//       if (snapshot.exists) {
//         Map<dynamic, dynamic> usersMap = snapshot.value as Map<dynamic, dynamic>;
//
//         String? userKey;
//         usersMap.forEach((key, value) {
//           if (value['email'] == currentUserEmail) {
//             userKey = key;
//           }
//         });
//
//         if (userKey != null) {
//           int currentCoins = usersMap[userKey]['coins'] ?? 0;
//           await usersRef.child(userKey!).update({'coins': currentCoins + 10});
//         }
//       }
//     } catch (e) {
//       print('Error adding reward: $e');
//     }
//   }
//
//   void showCongratulationDialog() {
//     showDialog(
//       context: context,
//       barrierDismissible: true,
//       builder: (context) {
//         return Dialog(
//           backgroundColor: Colors.transparent,
//           // insetPadding: const EdgeInsets.all(16),
//           child: Stack(
//             alignment: Alignment.topCenter,
//             children: [
//               // Main dialog image
//               Container(
//
//                   decoration: const BoxDecoration(
//                     image: DecorationImage(
//                       image: AssetImage('assets/images/Rectangle 71 (1).png'),
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                   height: 350,
//                   width: 280,
//                   child:Center(child:Image.asset('assets/images/Group 107.png',height:281,width:260))
//               ),
//
//               // Close button
//               Positioned(
//                 top: 1,
//                 right:  1,
//                 child: GestureDetector(
//                   onTap: () {
//                     Navigator.of(context).pop();
//                   },
//                   child: Image.asset(
//                     'assets/images/Group (4).png',
//                     width: 40,
//                     height: 40,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//
//     Future.delayed(const Duration(seconds: 1), () {
//       Navigator.of(context).pop();
//     });
//   }
//
//   Widget buildRewardItem(int index) {
//     int day = index + 1;
//     bool isCollected = day < currentDay;
//     bool isToday = day == currentDay;
//     bool isLocked = day > currentDay;
//
//     bool isDay7 = day == 7;
//     double boxWidth = (day == 7) ? 350 : 90;
//     double boxHeight = (day == 7) ? 100 : 90;
//
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: isDay7 ? 8 : 0),
//       child: SizedBox(
//         width: boxWidth,
//         height: boxHeight,
//         child: Stack(
//           children: [
//             Image.asset(
//               'assets/images/level_x5F_1.png',
//               width: boxWidth,
//               height: boxHeight,
//             ),
//             Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text(
//                     day.toString().padLeft(2, '0'),
//                     style: const TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.w700,
//                       color: Color(0xFF2E2E2E),
//                       fontFamily: 'LexendDeca',
//                     ),
//                   ),
//                   const Text(
//                     'DAY',
//                     style: TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.w700,
//                       color: Color(0xFF2E2E2E),
//                       fontFamily: 'LexendDeca',
//                     ),
//                   ),
//                   const SizedBox(height: 2),
//                   if (isCollected)
//                     const Text(
//                       "COLLECTED",
//                       style: TextStyle(
//                         fontSize: 10,
//                         fontWeight: FontWeight.bold,
//                         color: Color(0xFF2E2E2E),
//                         fontFamily: 'LexendDeca',
//                       ),
//                     )
//                   else if (isLocked || isToday)
//                     Text(
//                       isToday ? "Collected" : 'UnLocked',
//                       style: const TextStyle(
//                         fontSize: 10,
//                         fontWeight: FontWeight.bold,
//                         color: Color(0xFF2E2E2E),
//                         fontFamily: 'LexendDeca',
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//             if (isCollected || isToday)
//               Positioned(
//                 bottom: 4,
//                 right: 4,
//                 child: Image.asset(
//                   "assets/images/goldbg.png",
//                   width: 24,
//                 ),
//               )
//             else if (isLocked)
//               Positioned(
//                 bottom: 4,
//                 right: 4,
//                 child: Image.asset(
//                   "assets/images/LOCK (2).png",
//                   width: 20,
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     double brownBoxWidth = MediaQuery.of(context).size.width * 0.9;
//
//     return Scaffold(
//       body: Stack(
//         children: [
//           Image.asset(
//             "assets/images/background.png",
//             width: double.infinity,
//             height: double.infinity,
//             fit: BoxFit.cover,
//           ),
//           Center(
//             child: Stack(
//               alignment: Alignment.center,
//               children: [
//                 Image.asset(
//                   "assets/images/Group 171.png",
//                   width: brownBoxWidth,
//                 ),
//                 Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: List.generate(3, (i) => Padding(
//                         padding: const EdgeInsets.all(6.0),
//                         child: buildRewardItem(i),
//                       )),
//                     ),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: List.generate(3, (i) => Padding(
//                         padding: const EdgeInsets.all(6.0),
//                         child: buildRewardItem(i + 3),
//                       )),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: buildRewardItem(6),
//                     ),
//                   ],
//                 )
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
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
   //   showCongratulationDialog();
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
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/Rectangle 71 (1).png'),
                    fit: BoxFit.cover,
                  ),
                ),
                height: 350,
                width: 280,
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

    Future.delayed(const Duration(seconds: 1), () {
      Navigator.of(context).pop();
    });
  }

  Widget buildRewardItem(int index) {
    int day = index + 1;
    bool isCollected = day < currentDay;
    bool isToday = day == currentDay;
    bool isLocked = day > currentDay;

    bool isDay7 = day == 7;
    double boxWidth = isDay7 ? 350 : 90;
    double boxHeight = isDay7 ? 100 : 90;

    Widget rewardContent = SizedBox(
      width: boxWidth,
      height: boxHeight,
      child: Stack(
        children: [
          Image.asset(
            'assets/images/level_x5F_1.png',
            width: boxWidth,
            height: boxHeight,
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  day.toString().padLeft(2, '0'),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2E2E2E),
                    fontFamily: 'LexendDeca',
                  ),
                ),
                const Text(
                  'DAY',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2E2E2E),
                    fontFamily: 'LexendDeca',
                  ),
                ),
                const SizedBox(height: 2),
                if (isCollected)
                  const Text(
                    "COLLECTED",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E2E2E),
                      fontFamily: 'LexendDeca',
                    ),
                  )
                else if (isLocked || isToday)
                  Text(
                    isToday ? "Collected" : 'UnLocked',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E2E2E),
                      fontFamily: 'LexendDeca',
                    ),
                  ),
              ],
            ),
          ),
          if (isCollected || isToday)
            Positioned(
              bottom: 4,
              right: 4,
              child: Image.asset(
                "assets/images/goldbg.png",
                width: 24,
              ),
            )
          else if (isLocked)
            Positioned(
              bottom: 4,
              right: 4,
              child: Image.asset(
                "assets/images/LOCK (2).png",
                width: 20,
              ),
            ),
          // if (isDay7)
          //   Positioned(
          //     top: 4,
          //     left: 4,
          //     child: Image.asset(
          //       "assets/images/Group (7).png", // Optional decorative icon
          //       width: 24,
          //     ),
          //   ),
        ],
      ),
    );

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isDay7 ? 8 : 0),
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
    double brownBoxWidth = MediaQuery.of(context).size.width * 0.9;

    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            "assets/images/background.png",
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
          ),
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Image.asset(
                  "assets/images/Group 171.png",
                  width: brownBoxWidth,
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (i) => Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: buildRewardItem(i),
                      )),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (i) => Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: buildRewardItem(i + 3),
                      )),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          child: buildRewardItem(6), // Day 7
                        ),
                      ],
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
