import 'dart:math';

class HangmanWords {
  int wordCounter = 0;
  List<int> _usedNumbers = [];
  List<String> _words;

  HangmanWords(this._words); // Accept words list from Firebase

  void resetWords() {
    wordCounter = 0;
    _usedNumbers = [];
  }

  String? getWord() {
    if (wordCounter >= _words.length) return null;

    wordCounter += 1;
    var rand = Random();
    int wordLength = _words.length;
    int randNumber = rand.nextInt(wordLength);

    while (_usedNumbers.contains(randNumber)) {
      randNumber = rand.nextInt(wordLength);
    }

    _usedNumbers.add(randNumber);
    return _words[randNumber];
  }

  String getHiddenWord(int wordLength) {
    return '_' * wordLength;
  }
}
