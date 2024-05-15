import 'package:chat_bot/actions/action.dart';

import 'chat_bot_platform_interface.dart';

/// Class that holds most functions
/// that ChatBot can do
class ChatBot {
  /// Starts SpeechToText service in
  /// the android native side and return
  /// the detected text after he finishes.
  Future<String?> askChatBot() {
    return ChatBotPluginPlatform.instance.askChatBot();
  }

  Future<Action?> identifyAction(String text) {
    return ChatBotPluginPlatform.instance.identifyAction(text);
  }

}
