enum AnswerType { raw, choice }

class ActionAnswerChoice {
  final int id;
  final String title;

  ActionAnswerChoice({required this.id, required this.title});
}

class ActionAnswerResult {
  final AnswerType type;
  final dynamic answer; // * (type, answer) => (raw, String) or (choice, choice).

  ActionAnswerResult({required this.type, required this.answer});
}

class ActionAnswerRequest {
  final AnswerType type;
  final String? hintMessageBar;
  final List<ActionAnswerChoice> choices;
  final String expectedAnswer;

  ActionAnswerRequest.raw({this.type = AnswerType.raw, required this.expectedAnswer, required this.hintMessageBar, this.choices = const []});

  ActionAnswerRequest.choices({this.type = AnswerType.choice, required this.expectedAnswer, required this.hintMessageBar, required this.choices});
}
