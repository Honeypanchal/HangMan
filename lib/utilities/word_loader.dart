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

    const categoryMap = {
      'general knowledge': 'gk',
      'science and nature': 'science_and_nature',
      'history and politics': 'history_and_politics',
      'sports and games': 'sports_and_games',
      'geography and travel': 'geography_and_travel',
      'music and pop culture': 'music_and_pop_culture',
      'movies and tv shows': 'movies_and_manual',
      'literature and books': 'literature_and_books',
      'tech and creativity': 'tech_and_creativity',
    };

    final difficulty = userSnapshot.child('difficulty').value as String? ?? 'easy';
    final userCategory = userSnapshot.child('category').value as String? ?? 'general knowledge';
    final category = categoryMap[userCategory.toLowerCase()] ?? 'gk';

    print('Fetching words for difficulty: $difficulty, category: $category');

    final wordSnapshot = await FirebaseDatabase.instance
        .ref()
        .child('words/$difficulty/$category')
        .get();

    List<String> words = [];
    if (wordSnapshot.exists) {
      final data = wordSnapshot.value as List<dynamic>?; // Handle as list
      if (data != null) {
        for (var word in data) {
          final trimmedWord = word?.toString().trim() ?? '';
          if (trimmedWord.isNotEmpty) {
            words.add(trimmedWord);
          }
        }
      }
    } else {
      print('No words found at path: words/$difficulty/$category');
    }

    if (words.isEmpty) {
      throw Exception('No words available for difficulty: $difficulty, category: $category');
    }

    print('Fetched words: $words');
    return words;
  } catch (e) {
    print('Error fetching words: $e');
    rethrow;
  }
}