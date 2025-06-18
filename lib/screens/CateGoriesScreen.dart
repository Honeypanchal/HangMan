import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hangman/screens/DashBoeard.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final List<Map<String, String>> categories = [
    {
      "title": "GENERAL\nKNOWLEDGE",
      "image": "assets/images/General_Knowledge.png",
      "key": "gk"
    },
    {
      "title": "SCIENCE &\nNATURE",
      "image": "assets/images/Science___Nature.png",
      "key": "science_and_nature"
    },
    {
      "title": "HISTORY &\nPOLITICS",
      "image": "assets/images/History___Politics.png",
      "key": "history_and_politics"
    },
    {
      "title": "SPORTS &\nGAMES",
      "image": "assets/images/Sports___Games.png",
      "key": "sports_and_games"
    },
    {
      "title": "GEOGRAPHY &\nTRAVEL",
      "image": "assets/images/Geography___Travel.png",
      "key": "geography_and_travel"
    },
    {
      "title": "MUSIC &\nPOP CULTURE",
      "image": "assets/images/music-removebg.png",
      "key": "music_and_pop_culture"
    },
    {
      "title": "MOVIES &\nTV SHOWS",
      "image": "assets/images/movies.png",
      "key": "movies_and_tv_shows"
    },
    {
      "title": "LITERATURE &\nBOOKS",
      "image": "assets/images/Books.png",
      "key": "literature_and_books"
    },
    {
      "title": "TECH &\nCREATIVITY",
      "image": "assets/images/tech.png",
      "key": "tech_and_creativity"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.png',
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24,vertical: 12),
              padding: const EdgeInsets.only(top: 16,left: 12,right: 12),
              height: MediaQuery.of(context).size.height>900?500:MediaQuery.of(context).size.height>710?420:450,
              width: 380,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: const DecorationImage(
                  image: AssetImage('assets/images/Rectangle 71.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: categories.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 15,
                      crossAxisSpacing: 15,
                      childAspectRatio: 0.85,
                    ),
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      return GestureDetector(
                        onTap: () async {
                          final uid = FirebaseAuth.instance.currentUser?.uid;
                          if (uid != null) {
                            await FirebaseDatabase.instance
                                .ref()
                                .child('users/$uid')
                                .update({
                              'category': category['key']!,
                            });
                            print('DEBUG: Set category to ${category['key']} for user $uid');
                          }

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Category set to ${category['title']!.replaceAll('\n', ' ')}")),
                          );
                        },
                        child: Column(
                          children: [
                         SizedBox(
                             height: 100,


                              child: Image.asset(
                                category['image']!,

                               // fit: BoxFit.contain,
                              ),

                            ),
                           //SizedBox(height: 10,),
                           // const SizedBox(height: 15),
                           //  Text(
                           //    category['title']!,
                           //    style: const TextStyle(
                           //      fontWeight: FontWeight.bold,
                           //      fontFamily: 'Fredoka',
                           //      fontSize: 12,
                           //      height: 1.2,
                           //    ),
                           //    textAlign: TextAlign.center,
                           //  ),
                           //  SizedBox(height: 10,),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          Positioned(
              top: 180,
              right: 15,
              child: GestureDetector(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>Dashboard()));
                },
                child: Image.asset("assets/images/close_icon.png",
                  height: 50,
                  width: 50,),
              )),

        ],
      ),
    );
  }
}