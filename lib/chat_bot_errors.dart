import 'package:chat_bot/helpers/texts.dart';

final _errorsChatBot = [
  CBNoSpeechRecognizedError(),
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
      if (code == error.code) {
        return error;
      }
    }
    return null;
  }
}

class CBNoSpeechRecognizedError extends ChatBotError {
  CBNoSpeechRecognizedError() : super(code: 0, message: Texts.errorNoSpeechWasRecognized);
}

class CBNoInternetError extends ChatBotError {
  CBNoInternetError() : super(code: -1, message: Texts.errorNoInternetError);
}

class CBRecognizerBusyError extends ChatBotError {
  CBRecognizerBusyError() : super(code: -1, message: Texts.errorRecognizerBusy);
}

class CBNeedMicPermissionError extends ChatBotError {
  CBNeedMicPermissionError() : super(code: -1, message: Texts.errorNeedMicPermission);
}
