import 'dart:async';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hangman/components/AudioManager.dart';
import 'package:flutter_hangman/components/word_button.dart';
import 'package:flutter_hangman/screens/DashBoeard.dart';
import 'package:flutter_hangman/utilities/alphabet.dart';
import 'package:flutter_hangman/utilities/constants.dart';
import 'package:flutter_hangman/utilities/hangman_words.dart';
import 'package:flutter_hangman/utilities/score_db.dart' as score_database;
import 'package:flutter_hangman/utilities/user_scores.dart';
import '../utilities/hangman_ai.dart';
import '../utilities/word_loader.dart';
import '../components/DialogueBox.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with WidgetsBindingObserver {
  late HangmanWords hangmanObject;
  bool isLoading = true;
  String? errorMessage;

  int lives = 1; // Set to 1 for testing; change to 5 for normal play
  Alphabet englishAlphabet = Alphabet();
  String word = '';
  String hiddenWord = '';
  List<String> wordList = [];
  List<int> hintLetters = [];
  late List<bool> buttonStatus;
  late bool hintStatus;
  int hangState = 0;
  int wordCount = 0;
  bool finishedGame = false;
  bool resetGame = false;
  final int maxWordsToWin = 8;
  bool isMusicOn = true; // default to true
// AI fields
  late HangmanAI ai;
  String? aiSuggested;      // e.g. "E"
  int aiNodes = 0;
  int aiPruned = 0;
  int aiCandidates = 0;
  bool aiEnabled = true;    // Suggestion mode toggle (optional)

  // Timer variables
  bool isTimerOn = false;
  int seconds = 0; // For count-up (isTimerOn = false) or countdown (isTimerOn = true)
  Timer? _timer;
  bool isPaused = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    hintStatus = true;
    buttonStatus = List.generate(26, (_) => true);

    print("DEBUG: initState called, lives = $lives");

    AudioManager().init().then((_) {
      print("✅ AudioManager initialized and music started");
      print("✅ AudioManager initialized and music started");
      if (isMusicOn) AudioManager().playBackgroundMusic();
    });
    _loadSettings();
    _loadWordsFromFirebase();
  }

  Future<void> _loadWordsFromFirebase() async {
    try {
      final words = await fetchWordsFromFirebase();
      hangmanObject = HangmanWords(words);
      // Prepare AI with current pool (lowercase)
      final pool = hangmanObject.allWords.map((w) => w.toLowerCase()).toList();
      ai = HangmanAI(pool, maxDepth: 2); // depth 2 is safe & fast

      initWords();
      setState(() {
        isLoading = false;
        errorMessage = null;
      });
    } catch (e) {
      print("Error loading words: $e");
      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
    }
  }
  Set<String> _currentGuessedLetters() {
    final s = <String>{};
    for (int i = 0; i < 26; i++) {
      if (!buttonStatus[i]) s.add(englishAlphabet.alphabet[i]); // already guessed
    }
    return s;
  }

  int _remainingWrongGuesses() {
    // You lose when hangState == 6 in your code
    return (6 - hangState).clamp(0, 6);
  }
  void _recomputeAISuggestion() {
    if (!aiEnabled || isLoading || errorMessage != null) return;

    final suggestion = ai.suggest(
      pattern: hiddenWord.toLowerCase().replaceAll(' ', ''),
      guessed: _currentGuessedLetters(),
      remainingWrongGuesses: _remainingWrongGuesses(),
    );

    setState(() {
      aiSuggested = suggestion.letter; // already uppercase
      aiNodes = suggestion.nodesVisited;
      aiPruned = suggestion.branchesPruned;
      aiCandidates = suggestion.candidateCount;
    });
  }


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload settings when returning to GameScreen
    _loadSettings();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print("📲 Lifecycle changed: $state");
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      print("⏹ Paused/Inactivated – trying to stop audio now");
      AudioManager().forceStopAllAudio();
    }
  }


  void _pauseGame() {
    print("⏸️ Pausing game logic");
    isPaused = true;
    _timer?.cancel();
  }

  void _cleanup() {
    print("🧹 Cleaning up game resources");
    _timer?.cancel();
    AudioManager().dispose(); // Stop and dispose audio
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _cleanup(); // Ensure cleanup on widget dispose
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final snapshot = await FirebaseDatabase.instance
            .ref('users/${user.uid}/settings/timerOn')
            .get();
        setState(() {
          isTimerOn = snapshot.value as bool? ?? false;
          // Only reset seconds if timer mode changes
          if ((isTimerOn && seconds == 0) || (!isTimerOn && seconds == 300)) {
            seconds = isTimerOn ? 300 : 0;
          }
          _startTimer();
        });
      } catch (e) {
        print("DEBUG: Error loading settings: $e");
      }
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!isPaused) {
        setState(() {
          if (isTimerOn) {
            if (seconds > 0) {
              seconds--;
            } else {
              _timer?.cancel();
              print("DEBUG: Timer reached 00:00, showing GameOverDialog");
              finishedGame = true;
              lives = 0;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                GameOverDialog.show(
                  context,
                  onRetry: () {
                    print("DEBUG: Retry pressed");
                    newGame();
                    Navigator.pop(context);
                  },
                  onExit: () {
                    print("DEBUG: Exit pressed");
                    returnHomePage();
                  },
                );
              });
            }
          } else {
            seconds++;
          }
        });
      }
    });
  }

  String _formatTimer(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return "$minutes:$secs";
  }

  Future<void> _awardCoins(int coins) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("DEBUG: No user logged in, cannot award coins");
      return;
    }
    try {
      final userRef = FirebaseDatabase.instance.ref('users/${user.uid}');
      await userRef.child('coins').runTransaction((currentCoins) {
        final int newCoins = (currentCoins as int? ?? 0) + coins;
        return Transaction.success(newCoins);
      });
      print("DEBUG: Awarded $coins coins to user ${user.uid}");
    } catch (e) {
      print("DEBUG: Error awarding coins: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error awarding coins: $e")),
      );
    }
  }

  void newGame() {
    print("DEBUG: Starting new game");
    setState(() {
      hangmanObject.resetWords();
      englishAlphabet = Alphabet();
      lives = 1; // Set to 1 for testing; change to 5 for normal play
      wordCount = 0;
      finishedGame = false;
      resetGame = false;
      hintStatus = true;
      seconds = isTimerOn ? 300 : 0; // Reset timer
      isPaused = false;
      _startTimer();
      initWords();
    });
  }

  Widget createButton(index) {
    return Container(
      padding: const EdgeInsets.all(4.0),
      margin: const EdgeInsets.all(2.0),
      child: Center(
        child: WordButton(
          buttonTitle: englishAlphabet.alphabet[index].toUpperCase(),
          onPress: buttonStatus[index] ? () => wordPress(index) : () {},
          isEnabled: buttonStatus[index],
        ),
      ),
    );
  }

  void returnHomePage() {
    print("DEBUG: Navigating to Dashboard, current route: ${ModalRoute.of(context)?.settings.name}");
    _timer?.cancel(); // Stop timer on exit
    _cleanup(); // Clean up audio and resources
    try {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Dashboard()));
    } catch (e) {
      print("DEBUG: Navigation error: $e");
    }
  }

  void initWords() {
    print("DEBUG: Initializing new word");
    finishedGame = false;
    resetGame = false;
    hangState = 0;
    buttonStatus = List.generate(26, (_) => true);
    wordList = [];
    hintLetters = [];
    hintStatus = true;
    seconds = isTimerOn ? 300 : 0; // Reset timer
    _startTimer();


    final newWord = hangmanObject.getWord();
    if (newWord == null || newWord.isEmpty) {
      setState(() {
        errorMessage = "No words available";
      });
      return;
    }

    word = newWord;
    hiddenWord = hangmanObject.getHiddenWord(word.length);
    _recomputeAISuggestion();


    for (int i = 0; i < word.length; i++) {
      wordList.add(word[i]);
      hintLetters.add(i);
    }
    print("DEBUG: New word = $word, hiddenWord = $hiddenWord");
  }

  void wordPress(int index) {
    print("DEBUG: wordPress called, letter = ${englishAlphabet.alphabet[index]}, lives = $lives, hangState = $hangState");
    if (lives <= 0) {
      print("DEBUG: Lives <= 0, navigating to home");
      returnHomePage();
      return;
    }
    if (finishedGame) {
      print("DEBUG: Game finished, resetting");
      setState(() {
        resetGame = true;
      });
      return;
    }
    bool check = false;
    setState(() {
      for (int i = 0; i < wordList.length; i++) {
        if (wordList[i] == englishAlphabet.alphabet[index]) {
          check = true;
          wordList[i] = '';
          hiddenWord = hiddenWord.replaceFirst(RegExp('_'), word[i], i);
        }
      }
      for (int i = 0; i < wordList.length; i++) {
        if (wordList[i] == '') {
          hintLetters.remove(i);
        }
      }
      if (!check) {
        hangState += 1;
        print("DEBUG: Incorrect guess, hangState = $hangState");
      }
      if (hangState == 6) {
        finishedGame = true;
        lives -= 1;
        print("DEBUG: hangState == 6, lives = $lives");
        if (lives < 1) {
          print("DEBUG: Game over, showing GameOverDialog");
          if (wordCount > 0) {
            Score score = Score(
              id: null,
              scoreDate: DateTime.now().toString(),
              userScore: wordCount,
            );
            print("DEBUG: Saving score: $wordCount");
            score_database.manipulateDatabase(score);
          }
          WidgetsBinding.instance.addPostFrameCallback((_) {
            AudioManager().playloseSound();
            GameOverDialog.show(
              context,
              onRetry: () {
                print("DEBUG: Retry pressed");
                newGame();
                Navigator.pop(context);
              },
              onExit: () {
                print("DEBUG: Exit pressed");
                returnHomePage();
              },
            );
          });
        } else {
          print("DEBUG: Initializing new word (lives >= 1)");
          initWords();
        }
      }
      buttonStatus[index] = false;
      if (hiddenWord == word) {
        finishedGame = true;
        wordCount += 1;
        print("DEBUG: Word completed, wordCount = $wordCount");
        if (wordCount >= maxWordsToWin) {
          print("DEBUG: User won, awarding 10 coins and showing WinnerDialog");
          _awardCoins(10);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            AudioManager().playwinSound();
            WinnerDialog.show(
              context,
              onRetry: () {
                print("DEBUG: Next Level pressed");
                newGame();
                Navigator.pop(context);
              },
              onExit: () {
                print("DEBUG: Home pressed");
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const Dashboard()));
              },
            );
          });
        } else {
          initWords();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (resetGame) {
      setState(() {
        initWords();
      });
    }
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          _cleanup(); // Clean up on back press attempt
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/background.png"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Image.asset(
                'assets/images/$hangState.png',
                fit: BoxFit.contain,
                height: 300,
                gaplessPlayback: true,
              ),
            ),
            SafeArea(
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            // Background pill container with timer
                            Container(
                              height: 43,
                              width: 110,
                              decoration: BoxDecoration(
                                color: const Color.fromRGBO(0, 0, 0, 0.25),
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Row(
                                children: [
                                  const SizedBox(width: 40), // leave space for the clock
                                  Expanded(
                                    child: Text(
                                      _formatTimer(seconds),
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontFamily: 'Fredoka',
                                        fontWeight: FontWeight.w600,
                                        fontSize: 19,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Positioned clock image on the left side, overlapping
                            Positioned(
                              left: 0,
                              top: 0,
                              child: Image.asset(
                                "assets/images/clock.png",
                                height: 48,
                                width: 48,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                print("DEBUG: Pause button pressed");
                                setState(() {
                                  isPaused = true; // Pause timer
                                });
                                PauseDialog.show(
                                  context,
                                  onResume: () {
                                    print("DEBUG: Resume pressed from PauseDialog");
                                    setState(() {
                                      isPaused = false; // Resume timer
                                    });
                                  },
                                  onRetry: () {
                                    print("DEBUG: Retry pressed from PauseDialog");
                                    newGame();
                                  },
                                  onExit: () {
                                    print("DEBUG: Quit pressed from PauseDialog");
                                    returnHomePage();
                                  },
                                );
                              },
                              child: SizedBox(
                                width: 55,
                                height: 55,
                                child: Image.asset("assets/images/pause_button.png"),
                              ),
                            ),

                            // GestureDetector(
                            //   onTap: hintStatus
                            //       ? () {
                            //     int rand = Random()
                            //         .nextInt(hintLetters.length);
                            //     wordPress(englishAlphabet.alphabet
                            //         .indexOf(
                            //         wordList[hintLetters[rand]]));
                            //     hintStatus = false;
                            //   }
                            //       : null,
                            //   child:const Icon(
                            //
                            //     Icons.lightbulb,
                            //
                            //   ),
                            // ),
                            GestureDetector(
                              onTap: () {
                                // 1) Recompute to be safe
                                _recomputeAISuggestion();
                                // 2) If you want tap to auto-play suggestion, uncomment next lines:
                                // if (aiSuggested != null) {
                                //   final idx = englishAlphabet.alphabet.indexOf(aiSuggested!.toLowerCase());
                                //   if (idx >= 0 && buttonStatus[idx]) {
                                //     wordPress(idx);
                                //   }
                                // }
                              },
                              child: Column(
                                children: [
                                  SizedBox(
                                    width: 55,
                                    height: 55,
                                    child: Image.asset("assets/images/hint_bulb.png"), // use your bulb asset
                                  ),
                                  if (aiSuggested != null)
                                    Text(
                                      "AI: $aiSuggested",
                                      style: const TextStyle(
                                        fontFamily: 'Fredoka',
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                        color: Colors.white,
                                      ),
                                    ),
                                ],
                              ),
                            ),





                          ],
                        )


                      ],
                    ),
                  ),
                  Expanded(
                    child: isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : errorMessage != null
                        ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Error: $errorMessage",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              shadows: [
                                Shadow(
                                  blurRadius: 2.0,
                                  color: Colors.black,
                                  offset: Offset(1.0, 1.0),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                isLoading = true;
                                errorMessage = null;
                              });
                              _loadWordsFromFirebase();
                            },
                            child: const Text("Retry"),
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: returnHomePage,
                            child: const Text("Return to Home"),
                          ),
                        ],
                      ),
                    )
                        : Column(
                      children: [
                        Expanded(
                          flex: 5,
                          child: Container(
                            margin: const EdgeInsets.only(left: 35.0, right: 35.0, top: 240),
                            alignment: Alignment.center,
                            child: FittedBox(
                              fit: BoxFit.fitWidth,
                              child: Text(
                                hiddenWord.toUpperCase(),
                                style: kWordTextStyle.copyWith(
                                  color: Colors.white,
                                  shadows: const [
                                    Shadow(
                                      blurRadius: 2.0,
                                      color: Colors.black,
                                      offset: Offset(1.0, 1.0),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.fromLTRB(10.0, 2.0, 8.0, 14.0),
                          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 15.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Table(
                            defaultVerticalAlignment: TableCellVerticalAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              TableRow(children: [
                                TableCell(child: createButton(0)),
                                TableCell(child: createButton(1)),
                                TableCell(child: createButton(2)),
                                TableCell(child: createButton(3)),
                                TableCell(child: createButton(4)),
                                TableCell(child: createButton(5)),
                                TableCell(child: createButton(6)),
                              ]),
                              TableRow(children: [
                                TableCell(child: createButton(7)),
                                TableCell(child: createButton(8)),
                                TableCell(child: createButton(9)),
                                TableCell(child: createButton(10)),
                                TableCell(child: createButton(11)),
                                TableCell(child: createButton(12)),
                                TableCell(child: createButton(13)),
                              ]),
                              TableRow(children: [
                                TableCell(child: createButton(14)),
                                TableCell(child: createButton(15)),
                                TableCell(child: createButton(16)),
                                TableCell(child: createButton(17)),
                                TableCell(child: createButton(18)),
                                TableCell(child: createButton(19)),
                                TableCell(child: createButton(20)),
                              ]),
                              TableRow(children: [
                                TableCell(child: createButton(21)),
                                TableCell(child: createButton(22)),
                                TableCell(child: createButton(23)),
                                TableCell(child: createButton(24)),
                                TableCell(child: createButton(25)),
                                const TableCell(child: SizedBox()),
                                const TableCell(child: SizedBox()),
                              ]),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}