import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DailyRewardPage extends StatefulWidget {
  @override
  _DailyRewardPageState createState() => _DailyRewardPageState();
}

class _DailyRewardPageState extends State<DailyRewardPage> {
  int currentDay = 1;
  late SharedPreferences prefs;

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

    if (lastClaim != null) {
      DateTime lastClaimedDate = DateTime.parse(lastClaim);
      if (now.difference(lastClaimedDate).inHours >= 24) {
        day = (day + 1).clamp(1, 7);
        await prefs.setString('lastClaimedDate', now.toIso8601String());
        await prefs.setInt('currentDay', day);
      }
    } else {
      await prefs.setString('lastClaimedDate', now.toIso8601String());
      await prefs.setInt('currentDay', day);
    }

    setState(() {
      currentDay = day;
    });
  }

  Widget buildRewardItem(int index) {
    int day = index + 1;
    bool isCollected = day < currentDay;
    bool isToday = day == currentDay;
    bool isLocked = day > currentDay;

    bool isDay7 = day == 7;
    double boxWidth = (day == 7) ? 350 : 90;
    double boxHeight = (day == 7) ? 100 : 90;


    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isDay7 ? 8 : 0), // give extra horizontal padding for day 7
      child: SizedBox(
        width: boxWidth,
        height: boxHeight,
        child: Stack(
          children: [
            // Reward box background
            Image.asset(
              'assets/images/level_x5F_1.png',
              width: boxWidth,
              height: boxHeight,
            ),

            // Center text
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    day.toString().padLeft(2, '0'),
                    style: TextStyle(
                      fontSize: isDay7 ? 20 : 20,

                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2E2E2E),
                      fontFamily: 'LexendDeca',
                    ),
                  ),
                  Text(
                    'DAY',
                    style: TextStyle(
                      fontSize: isDay7 ? 20 : 20,
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

            // Bottom-right icon
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
          ],
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    double brownBoxWidth = MediaQuery.of(context).size.width * 0.9;

    return Scaffold(
      body: Stack(
        children: [
          // Full background image
          Image.asset(
            "assets/images/background.png",
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
          ),

          // Center content
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Brown rounded box under all rewards
                Image.asset(
                  "assets/images/Group 171.png", // the brown box behind all 7 rewards
                  width: brownBoxWidth,
                ),

                // Rewards grid placed over
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
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: buildRewardItem(6), // Day 7 box
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
