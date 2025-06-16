class Score {
  final String? id; // String for Firebase keys
  final String scoreDate;
  final int userScore;

  Score({
    this.id,
    required this.scoreDate,
    required this.userScore,
  });

  Map<String, dynamic> toMap() {
    return {
      'scoreDate': scoreDate,
      'userScore': userScore,
    };
  }

  @override
  String toString() {
    return 'Score{id: $id, scoreDate: $scoreDate, userScore: $userScore}';
  }
}