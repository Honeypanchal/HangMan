import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

Future<List<String>> fetchWordsFromFirebase() async {
  try {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      throw Exception('User not authenticated');
    }
    final userRef = FirebaseDatabase.instance.ref().child('users/$uid');
    final userSnapshot = await userRef.get();

    final difficulty = userSnapshot.child('difficulty').value as String? ?? 'easy';
    final category = userSnapshot.child('category').value as String? ?? 'gk';

    print('DEBUG: User $uid, difficulty: $difficulty, category: $category');

    final wordSnapshot = await FirebaseDatabase.instance
        .ref()
        .child('words/$difficulty/$category')
        .get();

    List<String> words = [];
    if (wordSnapshot.exists) {
      final data = wordSnapshot.value as List<dynamic>?;
      if (data != null) {
        for (var word in data) {
          final trimmedWord = word?.toString().trim() ?? '';
          if (trimmedWord.isNotEmpty) {
            words.add(trimmedWord);
          }
        }
      }
    } else {
      print('DEBUG: No words found at path: words/$difficulty/$category');
    }

    if (words.isEmpty) {
      throw Exception('No words available for difficulty: $difficulty, category: $category');
    }

    print('DEBUG: Fetched words: $words');
    return words;
  } catch (e) {
    print('DEBUG: Error fetching words: $e');
    rethrow;
  }
}