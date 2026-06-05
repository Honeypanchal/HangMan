// lib/ai/hangman_ai.dart
import 'dart:math';

class AISuggestion {
  final String letter;
  final int depthUsed;
  final int nodesVisited;
  final int branchesPruned;
  final int candidateCount;

  AISuggestion({
    required this.letter,
    required this.depthUsed,
    required this.nodesVisited,
    required this.branchesPruned,
    required this.candidateCount,
  });
}

class HangmanAI {
  final List<String> dictionary; // lowercased words only
  final int maxDepth;
  int _nodes = 0;
  int _pruned = 0;

  HangmanAI(this.dictionary, {this.maxDepth = 2});

  AISuggestion suggest({
    required String pattern,            // e.g. "__a_e"
    required Set<String> guessed,       // e.g. {'a','s','t'}
    required int remainingWrongGuesses, // 6 - hangState in your UI
  }) {
    _nodes = 0;
    _pruned = 0;

    final pat = _normalizePattern(pattern);
    final guessedLower = guessed.map((e) => e.toLowerCase()).toSet();
    final candidates = _filterCandidates(pat, guessedLower);

    // Fallback: if nothing matches (rare), use global frequency
    if (candidates.isEmpty) {
      final pick = _globalFrequencyPick(guessedLower);
      return AISuggestion(
        letter: pick,
        depthUsed: 0,
        nodesVisited: _nodes,
        branchesPruned: _pruned,
        candidateCount: 0,
      );
    }

    final unguessed = _alphabet().where((c) => !guessedLower.contains(c)).toList();
    // Letter ordering: frequency in candidates (improves pruning)
    unguessed.sort((a, b) =>
        _letterFrequency(b, candidates).compareTo(_letterFrequency(a, candidates)));

    double bestScore = double.negativeInfinity;
    String bestLetter = unguessed.first;

    for (final ch in unguessed) {
      final score = _minValue(
        pat,
        guessedLower,
        remainingWrongGuesses,
        candidates,
        ch,
        -1e18,
        1e18,
        depth: 0,
      );
      if (score > bestScore) {
        bestScore = score;
        bestLetter = ch;
      }
    }

    return AISuggestion(
      letter: bestLetter.toUpperCase(),
      depthUsed: maxDepth,
      nodesVisited: _nodes,
      branchesPruned: _pruned,
      candidateCount: candidates.length,
    );
  }

  // ---------- Minimax with alpha-beta ----------

  double _maxValue(
      String pattern,
      Set<String> guessed,
      int remainingWrong,
      List<String> candidates,
      double alpha,
      double beta, {
        required int depth,
      }) {
    _nodes++;

    // Terminal / cutoff
    if (remainingWrong <= 0) return -1e12;         // lost
    if (!_hasUnderscore(pattern)) return 1e12;     // solved
    if (depth >= maxDepth) return _evaluate(candidates, remainingWrong);

    // Order next letters by frequency
    final unguessed = _alphabet().where((c) => !guessed.contains(c)).toList();
    unguessed.sort((a, b) =>
        _letterFrequency(b, candidates).compareTo(_letterFrequency(a, candidates)));

    double v = double.negativeInfinity;
    for (final ch in unguessed) {
      final score = _minValue(
        pattern,
        guessed,
        remainingWrong,
        candidates,
        ch,
        alpha,
        beta,
        depth: depth,
      );
      v = max(v, score);
      if (v >= beta) {
        _pruned++;
        return v;
      }
      alpha = max(alpha, v);
    }
    return v;
  }

  double _minValue(
      String pattern,
      Set<String> guessed,
      int remainingWrong,
      List<String> candidates,
      String aiChoice,
      double alpha,
      double beta, {
        required int depth,
      }) {
    _nodes++;

    // Opponent/environment picks worst partition for us
    // Partition candidates by resulting pattern after guessing aiChoice
    final partitions = <String, List<String>>{};
    for (final w in candidates) {
      final newPat = _applyGuessToPattern(w, pattern, aiChoice);
      final key = '$newPat|${w.contains(aiChoice) ? 1 : 0}';
      (partitions[key] ??= []).add(w);
    }

    double v = double.infinity;
    for (final entry in partitions.entries) {
      final parts = entry.key.split('|');
      final newPattern = parts.first;
      final hit = parts.last == '1';
      final newRemaining = remainingWrong - (hit ? 0 : 1);

      final newGuessed = Set<String>.from(guessed)..add(aiChoice);

      final score = _maxValue(
        newPattern,
        newGuessed,
        newRemaining,
        entry.value,
        alpha,
        beta,
        depth: depth + 1,
      );
      v = min(v, score);
      if (v <= alpha) {
        _pruned++;
        return v;
      }
      beta = min(beta, v);
    }
    return v;
  }

  // ---------- Heuristic & helpers ----------

  double _evaluate(List<String> candidates, int remainingWrong) {
    // Smaller candidate set is better. Slight bonus for more lives left.
    return -candidates.length + remainingWrong * 0.05;
  }

  List<String> _filterCandidates(String pattern, Set<String> guessed) {
    final wrong = guessed.where((c) => !pattern.contains(c)).toSet();
    final known = <int, String>{};
    for (int i = 0; i < pattern.length; i++) {
      final ch = pattern[i];
      if (ch != '_' && ch != '*') known[i] = ch;
    }

    return dictionary.where((w) {
      if (w.length != pattern.length) return false;

      // All known letters must match
      for (final e in known.entries) {
        if (w[e.key] != e.value) return false;
      }

      // No wrong letters may appear in the word
      for (final c in wrong) {
        if (w.contains(c)) return false;
      }

      // If pattern has a letter at pos i, it must be that exact letter
      // (Already enforced by 'known')

      return true;
    }).toList();
  }

  int _letterFrequency(String ch, List<String> words) {
    int count = 0;
    for (final w in words) {
      if (w.contains(ch)) count++;
    }
    return count;
  }

  String _globalFrequencyPick(Set<String> guessed) {
    final words = dictionary;
    final letters = _alphabet().where((c) => !guessed.contains(c)).toList();
    letters.sort((a, b) => _letterFrequency(b, words).compareTo(_letterFrequency(a, words)));
    return letters.isEmpty ? 'e' : letters.first;
  }

  String _applyGuessToPattern(String word, String pattern, String guess) {
    final b = StringBuffer();
    for (int i = 0; i < word.length; i++) {
      if (word[i] == guess || (pattern[i] != '_' && pattern[i] != '*')) {
        b.write(word[i]);
      } else {
        b.write('_');
      }
    }
    return b.toString();
  }

  String _normalizePattern(String p) => p.replaceAll(' ', '').toLowerCase();
  bool _hasUnderscore(String p) => p.contains('_');
  List<String> _alphabet() => 'abcdefghijklmnopqrstuvwxyz'.split('');
}
