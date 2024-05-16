import 'dart:ffi';

import 'package:chat_bot/actions/actions.dart';

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

  Future<Void?> performAction(Action action, [List<dynamic> args = const []]) {
    // ignore: avoid_print
    print("[FP-ChatBot:performAction]: Performing '${action.name}' with args '$args'.");
    return ChatBotPluginPlatform.instance.performAction(action, args);
  }
}
