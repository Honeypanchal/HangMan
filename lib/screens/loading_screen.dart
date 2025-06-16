import 'package:flutter/material.dart';
import 'package:flutter_hangman/screens/score_screen.dart';
import 'package:flutter_hangman/utilities/score_db.dart' as score_database;
import 'package:flutter_hangman/utilities/user_scores.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  LoadingScreenState createState() => LoadingScreenState();
}

class LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    queryScores();
  }

  void queryScores() async {
    try {
      List<Score> queryResult = await score_database.scores();
      goToScoreScreen(queryResult);
    } catch (e) {
      print("Error querying scores: $e");
      // Handle error (e.g., show error UI or retry)
      goToScoreScreen([]); // Fallback to empty list
    }
  }

  void goToScoreScreen(List<Score> queryResult) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) {
          return ScoreScreen(
            query: queryResult,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Ensure visible background
      body: const Center(
        child: SpinKitDoubleBounce(
          color: Colors.blue, // Adjust color for visibility
          size: 100.0,
        ),
      ),
    );
  }
}