import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_hangman/utilities/createMultiplayerGame.dart';

class CreateGameScreen extends StatefulWidget {
  const CreateGameScreen({super.key});

  @override
  State<CreateGameScreen> createState() => _CreateGameScreenState();
}

class _CreateGameScreenState extends State<CreateGameScreen> {
  String? selectedCategory;
  String? selectedDifficulty;
  String? inviteCode;
  bool isLoading = false;
  bool opponentJoined = false;
  String gameCode = '';
  StreamSubscription<DatabaseEvent>? _gameListener;

  final List<String> difficulties = ['beginner', 'easy', 'medium'];
  final List<String> categories = [
    'gk',
    'science_and_nature',
    'history_and_politics',
    'sports_and_games',
    'geography_and_travel',
    'music_and_pop_culture',
    'movies_and_tv_shows',
    'literature_and_books',
    'tech_and_creativity'
  ];

  void createGame() async {
    if (selectedCategory == null || selectedDifficulty == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select both difficulty and category")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final snapshot = await FirebaseDatabase.instance
          .ref("words/${selectedDifficulty!}/${selectedCategory!}")
          .get();

      if (!snapshot.exists) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("No words found for this category/difficulty")),
        );
        return;
      }

      final List wordList = List.from(snapshot.value as List);
      wordList.shuffle();
      final word = wordList.first;

      final code = await createMultiplayerGame(
        category: selectedCategory!,
        difficulty: selectedDifficulty!,
        word: word,
      );

      setState(() {
        inviteCode = code;
        gameCode = code;
        isLoading = false;
      });

      // Start listening for opponent join
      _gameListener = FirebaseDatabase.instance
          .ref("multiplayerGames/$code")
          .onValue
          .listen((event) {
        final data = event.snapshot.value as Map?;
        if (data == null) return;
        if (data['player2Uid'] != null && mounted) {
          setState(() {
            opponentJoined = true;
          });
        }
      }) as StreamSubscription<DatabaseEvent>?;
    } catch (e) {
      print("❌ Error: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    _gameListener?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Multiplayer Game")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButton<String>(
              hint: const Text("Select Difficulty"),
              value: selectedDifficulty,
              items: difficulties.map((d) {
                return DropdownMenuItem(
                    value: d,
                    child: Text(d.toUpperCase(),
                        style: const TextStyle(color: Colors.white)));
              }).toList(),
              onChanged: (val) => setState(() => selectedDifficulty = val),
            ),
            DropdownButton<String>(
              hint: const Text("Select Category"),
              value: selectedCategory,
              items: categories.map((c) {
                return DropdownMenuItem(
                    value: c,
                    child:
                    Text(c, style: const TextStyle(color: Colors.white)));
              }).toList(),
              onChanged: (val) => setState(() => selectedCategory = val),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoading ? null : createGame,
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Create Game"),
            ),
            const SizedBox(height: 30),

                      ],
        ),
      ),
    );
  }
}
