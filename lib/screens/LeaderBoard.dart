import 'package:flutter/material.dart';

import 'package:firebase_database/firebase_database.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

import 'package:flutter_hangman/screens/DashBoeard.dart';



class LeaderBoard extends StatefulWidget {
  static String routeName = '/leaderboard';
  const LeaderBoard({super.key});

  @override
  State<LeaderBoard> createState() => _LeaderBoardState();
}

class _LeaderBoardState extends State<LeaderBoard> {
  double _topCloudPosition = -200; // Initially off-screen
  double _bottomCloudPosition = -140;
  // Realtime Database instance
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final String? currentUserEmail = FirebaseAuth.instance.currentUser?.email;

  List<Map<String, dynamic>> leaderboardData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // Start animation after a slight delay
    fetchLeaderboardData();

  }

  // Fetch leaderboard data from Realtime Database
  Future<void> fetchLeaderboardData() async {
    try {
      DatabaseReference usersRef = _database.child('users');
      DataSnapshot snapshot = await usersRef.get();

      if (snapshot.exists) {
        Map<dynamic, dynamic> usersMap = snapshot.value as Map<dynamic, dynamic>;

        List<Map<String, dynamic>> usersList = [];

        usersMap.forEach((uid, value) {
          usersList.add({
            'uid': value['uid'] ?? uid,
            'username': value['username'] ?? 'Unknown',
            'coins': value['coins'] ?? 0,
          });
        });

        // Sort by coins descending
        usersList.sort((a, b) => (b['coins'] as int).compareTo(a['coins'] as int));

        // Assign rank and build leaderboard
        leaderboardData = usersList.asMap().entries.map((entry) {
          int rank = entry.key + 1;
          var user = entry.value;
          return {
            'rank': rank,
            'uid': user['uid'],
            'name': user['username'], // this replaces old 'name'
            'coins': user['coins'],
          };
        }).toList();

        setState(() {
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No Users found")),
        );
      }
    } catch (e) {
      print('Error fetching leaderboard data: $e');
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to load leaderboard")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:

      Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/hangman_bg.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Stack(


            children: [
              // Gradient background with animated clouds

              Column(
                children: [
                  // Header (empty for now, can add back buttons later)
                  SizedBox(height: 5),

                  // Leaderboard list
                  Expanded(
                    child: isLoading
                        ? Center(
                      child: CircularProgressIndicator(
                        color: Color.fromRGBO(255, 215, 0, 1.0), // Golden Yellow
                      ),
                    )
                        : leaderboardData.isEmpty
                        ? Center(
                      child: Text(
                        'No users found.',
                        style: TextStyle(
                          color: Color.fromRGBO(255, 255, 255, 1.0),
                          fontSize: 18,
                        ),
                      ),
                    )
                        : Align(
                      alignment: Alignment.center,
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).
                            size.width>410?0:MediaQuery.of(context).size.width>350?20:10),
                            padding: EdgeInsets.only(top: 10,bottom: 20),
                                                width: 345,
                                                height: 510,
                                                decoration: BoxDecoration(
                          color: Color.fromRGBO(90, 48, 13, 0.9),

                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              offset: Offset(0, 10), // 0px horizontal, 10px vertical
                              blurRadius: 4, // 4px blur
                              spreadRadius: 0, // 0px spread
                              color: Color.fromRGBO(0, 0, 0, 0.25), // rgba(0, 0, 0, 0.25)
                            ),
                          ],
                                                ),
                                                child: ListView.builder(
                          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
                          itemCount: leaderboardData.length,
                          itemBuilder: (context, index) {
                            var user = leaderboardData[index];
                            final currentUid = FirebaseAuth.instance.currentUser?.uid;
                            final isCurrentUser = user['uid'] == currentUid;

                            return Column(
                              children: [
                                if (index == 0) SizedBox(height: 20), // 👈 Add this for top spacing
                                SizedBox(
                                  width: 308,
                                  height: 60,
                                  child: Card(
                                    color: isCurrentUser
                                        ? Colors.white
                                        : Color.fromRGBO(244, 204, 92, 1),
                                    elevation: 5,
                                    margin: EdgeInsets.symmetric(vertical: 8.0),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: ListTile(
                                      contentPadding: EdgeInsets.symmetric(horizontal: 12), // optional, for tighter fit
                                      leading: Text(
                                        '${user['rank']}.',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 21,
                                          fontFamily: 'NexaRustSans',
                                        ),
                                      ),
                                      title: Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 12, // smaller size to fit within 45 height
                                            backgroundColor: Colors.transparent,
                                            child: Image.asset(
                                              'assets/images/avatar.png',
                                              fit: BoxFit.cover,
                                              width: 30,
                                              height: 30,
                                            ),
                                          ),
                                          SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              isCurrentUser ? "YOU" : user['name'] ?? 'Unknown',
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 22,
                                                fontWeight: FontWeight.w500,
                                                fontFamily: 'Fredoka',
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            '${user['coins'] ?? 0}',
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 23,
                                              fontWeight: FontWeight.w500,
                                              fontFamily: 'Fredoka',
                                            ),
                                          ),
                                          SizedBox(width: 4),
                                          Image.asset(
                                            'assets/images/coin.png',
                                            width: 24,
                                            height: 24,
                                            errorBuilder: (context, error, stackTrace) {
                                              print('Error loading coin.png: $error');
                                              return Icon(Icons.error, color: Colors.red);
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                              ],
                            );
                          },

                                                ),
                                              ),
                        ),
                  ),
                ],
              ),
              SizedBox(height: 140,),
              Positioned(

                  top: MediaQuery.of(context).size.height>900?180:100,
                  right: MediaQuery.of(context).size.height>900?10:5,
                  child: GestureDetector(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>Dashboard()));
                    },
                    child: Image.asset("assets/images/close_icon.png",
                      height: 50,
                      width: 50,),
                  )),

              Positioned(

                top: MediaQuery.of(context).size.height>900?180:100,
                left: 0,
                right: 0,

                child: Center(
                  child: Container(

                    padding: EdgeInsets.symmetric(vertical: 8,
                        horizontal: 20),
                    decoration: BoxDecoration(
                        color: Color.fromRGBO(254, 204, 92, 1),
                        borderRadius: BorderRadius.circular(3),


                    ),
                    child: Text(
                      'LeaderBoard',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Fredoka',
                        color: Colors.black,
                      ),
                    ),
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