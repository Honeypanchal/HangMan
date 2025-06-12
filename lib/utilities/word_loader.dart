import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

Future<List<String>> fetchWordsFromFirebase() async {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  final userRef = FirebaseDatabase.instance.ref().child('users/$uid');
  final userSnapshot = await userRef.get();

  final difficulty = userSnapshot.child('difficulty').value as String?;
  final category = userSnapshot.child('category').value as String?;

  if (difficulty == null || category == null) {
    throw Exception('User difficulty or category not found');
  }

  final wordSnapshot = await FirebaseDatabase.instance
      .ref()
      .child('words/$difficulty/$category')
      .get();

  List<String> words = [];
  if (wordSnapshot.exists) {
    for (final child in wordSnapshot.children) {
      final word = child.value.toString().trim();
      if (word.isNotEmpty) words.add(word);
    }
  }

  return words;
}
