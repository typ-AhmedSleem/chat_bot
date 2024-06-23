import 'package:chat_bot/helpers/texts.dart';

final _errorsChatBot = [
  CBNoSpeechRecognizedError(),
  CBRecognizerUnavailable(),
  CBNoInternetError(),
  CBRecognizerBusyError(),
  CBNeedMicPermissionError(),
];

abstract class ChatBotError {
  int code;
  String message;

  ChatBotError({required this.code, required this.message});

  static ChatBotError? getErrorByCode(int code) {
    for (ChatBotError error in _errorsChatBot) {
      print("Checking error of code ${error.code} with $code");
      if (code == error.code) {
        print("Found error matching code $code");
        return error;
      }
    }
    print("No errors found to match code $code");
    return null;
  }
}

class CBError extends ChatBotError {
  CBError({super.code = -1, required super.message});

  @override
  String toString() {
    return "$runtimeType{code= $code, msg= '$message'}";
  }
}

class CBNoSpeechRecognizedError extends ChatBotError {
  CBNoSpeechRecognizedError() : super(code: 0, message: Texts.errorNoSpeechWasRecognized);
}

class CBRecognizerUnavailable extends ChatBotError {
  CBRecognizerUnavailable() : super(code: 14, message: Texts.recognizerNotAvailable);
}

class CBNoInternetError extends ChatBotError {
  CBNoInternetError() : super(code: 9, message: Texts.errorNoInternetError);
}

class CBRecognizerBusyError extends ChatBotError {
  CBRecognizerBusyError() : super(code: -1, message: Texts.errorRecognizerBusy);
}

class CBNeedMicPermissionError extends ChatBotError {
  CBNeedMicPermissionError() : super(code: 14, message: Texts.errorNeedMicPermission);
}
