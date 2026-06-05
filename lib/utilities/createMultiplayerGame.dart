import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:math';

String generateInviteCode() {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890';
  return List.generate(6, (index) => chars[Random().nextInt(chars.length)]).join();
}

Future<String> createMultiplayerGame({
  required String category,
  required String difficulty,
  required String word,
}) async {
  final dbRef = FirebaseDatabase.instance.ref();
  final inviteCode = generateInviteCode(); // Replace with your actual logic
  final currentUser = FirebaseAuth.instance.currentUser;

  if (currentUser == null) {
    print("❌ No current user found");
    throw Exception("User not authenticated");
  }

  final gameData = {
    'player1Uid': currentUser.uid,
    'player2Uid': '',
    'category': category,
    'difficulty': difficulty,
    'word': word,
    'guessedLetters': [],
    'wrongGuesses': 0,
    'maxAttempts': 7,
    'turn': currentUser.uid,
    'status': 'waiting',
    'createdAt': ServerValue.timestamp,
  };

  try {
    await dbRef.child('multiplayerGames').child(inviteCode).set(gameData);
    print("✅ Game created at multiplayerGames/$inviteCode");
    return inviteCode;
  } catch (e) {
    print("❌ Error writing to database: $e");
    rethrow;
  }
}
