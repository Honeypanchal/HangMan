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
    {"title": "GENERAL\nKNOWLEDGE", "image": "assets/images/General_Knowledge.png"},
    {"title": "SCIENCE &\nNATURE", "image": "assets/images/Science___Nature.png"},
    {"title": "HISTORY &\nPOLITICS", "image": "assets/images/History___Politics.png"},
    {"title": "SPORTS &\nGAMES", "image": "assets/images/Sports___Games.png"},
    {"title": "GEOGRAPHY &\nTRAVEL", "image": "assets/images/Geography___Travel.png"},
    {"title": "MUSIC &\nPOP CULTURE", "image": "assets/images/music-removebg.png"},
    {"title": "MOVIES &\nTV SHOWS", "image": "assets/images/movies.png"},
    {"title": "LITERATURE &\nBOOKS", "image": "assets/images/Books.png"},
    {"title": "TECH &\nCREATIVITY", "image": "assets/images/tech.png"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.png',
              fit: BoxFit.cover,
            ),
          ),

          // Centered Container
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(16),
              height:450,
              width:360,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),

                image: const DecorationImage(

                  image: AssetImage('assets/images/Rectangle 71.png',),
                  // 👈 your image here
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
                            await FirebaseDatabase.instance.ref().child('users/$uid').update({
                              'category': category['title']!,
                            });
                          }

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Category set to ${category['title']}")),
                          );
                        },
                        child: Column(
                          children: [
                            Expanded(
                              child: Image.asset(category['image']!, height: 100, width: 100, fit: BoxFit.contain),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              category['title']!,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Fredoka',
                                fontSize: 12,
                                height: 1.2,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    },

                  ),

                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=>Dashboeard()));
            },
            child: Container(
              height: 60,
              width: 250,
              decoration: BoxDecoration(
                color: Colors.brown,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white,width: 2),

              ),

              child: Text("Save"),),
          )

        ],
      ),
    );
  }
}
