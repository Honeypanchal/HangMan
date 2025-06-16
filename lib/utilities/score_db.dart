import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hangman/utilities/user_scores.dart';

Future<void> insertScore(Score score) async {
  try {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      debugPrint("Error: User not authenticated");
      return;
    }
    final dbRef = FirebaseDatabase.instance.ref().child('scores/$uid');
    await dbRef.push().set({
      'scoreDate': score.scoreDate,
      'userScore': score.userScore,
    });
  } catch (e) {
    debugPrint("Error inserting score: $e");
    rethrow;
  }
}

Future<List<Score>> scores() async {
  try {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      debugPrint("Error: User not authenticated");
      return [];
    }
    final snapshot = await FirebaseDatabase.instance.ref().child('scores/$uid').get();
    List<Score> scoreList = [];
    if (snapshot.exists) {
      final data = snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        data.forEach((key, value) {
          scoreList.add(Score(
            id: key, // Use Firebase key as ID
            scoreDate: value['scoreDate'],
            userScore: value['userScore'],
          ));
        });
      }
    }
    return scoreList;
  } catch (e) {
    debugPrint("Error fetching scores: $e");
    return [];
  }
}

Future<void> updateScore(Score score) async {
  try {
    if (score.id == null) return;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      debugPrint("Error: User not authenticated");
      return;
    }
    await FirebaseDatabase.instance
        .ref()
        .child('scores/$uid/${score.id}')
        .update({
      'scoreDate': score.scoreDate,
      'userScore': score.userScore,
    });
  } catch (e) {
    debugPrint("Error updating score: $e");
    rethrow;
  }
}

Future<void> deleteScore(String? id) async {
  try {
    if (id == null) return;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      debugPrint("Error: User not authenticated");
      return;
    }
    await FirebaseDatabase.instance.ref().child('scores/$uid/$id').remove();
  } catch (e) {
    debugPrint("Error deleting score: $e");
    rethrow;
  }
}

Future<void> manipulateDatabase(Score scoreObject) async {
  try {
    await insertScore(scoreObject);
    final data = await scores();
    debugPrint("Scores: $data");
  } catch (e) {
    debugPrint("Error manipulating database: $e");
  }
}