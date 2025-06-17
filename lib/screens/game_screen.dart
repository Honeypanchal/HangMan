import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_hangman/components/word_button.dart';
import 'package:flutter_hangman/screens/DashBoeard.dart';
import 'package:flutter_hangman/screens/home_screen.dart';
import 'package:flutter_hangman/utilities/alphabet.dart';
import 'package:flutter_hangman/utilities/constants.dart';
import 'package:flutter_hangman/utilities/hangman_words.dart';
import 'package:flutter_hangman/utilities/score_db.dart' as score_database;
import 'package:flutter_hangman/utilities/user_scores.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../utilities/word_loader.dart';
import '../components/DialogueBox.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
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

  @override
  void initState() {
    super.initState();
    hintStatus = true;
    buttonStatus = List.generate(26, (_) => true);
    print("DEBUG: initState called, lives = $lives");
    _loadWordsFromFirebase();
  }

  Future<void> _loadWordsFromFirebase() async {
    try {
      final words = await fetchWordsFromFirebase();
      hangmanObject = HangmanWords(words);
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

  void newGame() {
    print("DEBUG: Starting new game");
    setState(() {
      hangmanObject.resetWords();
      englishAlphabet = Alphabet();
      lives = 1; // Set to 1 for testing; change to 5 for normal play
      wordCount = 0;
      finishedGame = false;
      resetGame = false;
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
    print("DEBUG: Navigating to HomeScreen");
    Navigator.push(context, MaterialPageRoute(builder: (context)=>Dashboeard()));
  }

  void initWords() {
    print("DEBUG: Initializing new word");
    finishedGame = false;
    resetGame = false;
    hangState = 0;
    buttonStatus = List.generate(26, (_) => true); // Reset buttons
    wordList = [];
    hintLetters = [];

    final newWord = hangmanObject.getWord();
    if (newWord == null || newWord.isEmpty) {
      setState(() {
        errorMessage = "No words available";
      });
      return;
    }

    word = newWord;
    hiddenWord = hangmanObject.getHiddenWord(word.length);

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
      buttonStatus[index] = false; // Disable button
      if (hiddenWord == word) {
        finishedGame = true;
        wordCount += 1;
        print("DEBUG: Word completed, wordCount = $wordCount");

        // Check if the user has won (guessed maxWordsToWin words)
        if (wordCount >= maxWordsToWin) {
          print("DEBUG: User won, showing WinnerDialog");
          WidgetsBinding.instance.addPostFrameCallback((_) {
            WinnerDialog.show(
              context,
              onRetry: () {
                print("DEBUG: Next Level pressed");
                newGame();
                Navigator.pop(context);
              },
              onExit: () {
                print("DEBUG: Home pressed");
                returnHomePage();
                Navigator.pop(context);
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
                'images/$hangState.png',
                fit: BoxFit.contain,
                height: 300, // Reduced height to avoid overlap
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
                        Row(
                          children: <Widget>[
                            Stack(
                              children: <Widget>[
                                // Container(
                                //   padding: const EdgeInsets.only(top: 0.5),
                                //   child: IconButton(
                                //     tooltip: 'Lives',
                                //     highlightColor: Colors.transparent,
                                //     splashColor: Colors.transparent,
                                //     iconSize: 39,
                                //     icon: Icon(MdiIcons.heart),
                                //     onPressed: () {},
                                //   ),
                                // ),
                                // Container(
                                //   padding: const EdgeInsets.fromLTRB(8.7, 7.9, 0, 0.8),
                                //   alignment: Alignment.center,
                                //   child: SizedBox(
                                //     height: 38,
                                //     width: 38,
                                //     child: Center(
                                //       child: Padding(
                                //         padding: const EdgeInsets.all(2.0),
                                //         child: Text(
                                //           lives.toString() == "1" ? "I" : lives.toString(),
                                //           style: const TextStyle(
                                //             color: Color(0xFF2C1E68),
                                //             fontSize: 40,
                                //             fontWeight: FontWeight.bold,
                                //             fontFamily: 'PatrickHand',
                                //           ),
                                //         ),
                                //       ),
                                //     ),
                                //   ),
                                // ),
                                SizedBox(
                                  child: IconButton(
                                    tooltip: 'Hint',
                                    iconSize: 39,
                                    icon: Icon(MdiIcons.lightbulb),
                                    highlightColor: Colors.transparent,
                                    splashColor: Colors.transparent,
                                    onPressed: hintStatus
                                        ? () {
                                      if (hintLetters.isNotEmpty) {
                                        int rand = Random().nextInt(hintLetters.length);
                                        wordPress(englishAlphabet.alphabet
                                            .indexOf(wordList[hintLetters[rand]]));
                                        hintStatus = false;
                                      }
                                    }
                                        : null,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () {
                            print("DEBUG: Pause button pressed");
                            PauseDialog.show(
                              context,
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
                            child: Image.asset('assets/images/pause_button.png'),
                          ),
                        ),

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
                            margin: const EdgeInsets.only(left: 35.0,right: 35.0,top: 240),
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
                            //color: Colors.white.withOpacity(0.2),
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