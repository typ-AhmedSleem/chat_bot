class GameData {
  final Score score;
  final RecommendedGameDifficulty recommendedGameDifficulty;

  GameData({
    required this.score,
    required this.recommendedGameDifficulty,
  });

  factory GameData.fromJson(Map<String, dynamic> json) {
    return GameData(
      score: Score.fromJson(json['score']),
      recommendedGameDifficulty: RecommendedGameDifficulty.of(json['recommendedGameDifficulty']),
    );
  }
}

class Score {
  final int currentScore;
  final int maxScore;

  Score({
    required this.currentScore,
    required this.maxScore,
  });

  factory Score.fromJson(Map<String, dynamic> json) {
    return Score(
      currentScore: json['currentScore'],
      maxScore: json['maxScore'],
    );
  }
}

enum RecommendedGameDifficulty {
  easy,
  medium,
  hard;

  static RecommendedGameDifficulty of(int value) {
    switch (value) {
      case 0:
        return RecommendedGameDifficulty.easy;
      case 1:
        return RecommendedGameDifficulty.medium;
      case 2:
        return RecommendedGameDifficulty.hard;
      default:
        throw ArgumentError('Invalid game difficulty value: $value');
    }
  }
}
