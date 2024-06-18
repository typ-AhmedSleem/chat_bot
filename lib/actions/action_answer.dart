class ActionAnswerRequest {
  final String? hintMessageBar;
  final String expectedAnswer;
  String? submittedAnswer;

  ActionAnswerRequest({required this.expectedAnswer, required this.hintMessageBar});

  void submitAnswer(String answer) {
    submittedAnswer = answer;
  }

  bool get isAnswerSubmitted => (submittedAnswer != null);

  bool get isAnswerCorrect {
    if (submittedAnswer == null) return false;
    return expectedAnswer == submittedAnswer;
  }
}
