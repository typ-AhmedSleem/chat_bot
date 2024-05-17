import 'dart:ffi';

import 'package:chat_bot/actions/actions.dart';

import 'chat_bot_platform_interface.dart';
import 'logger.dart';

/// Class that holds most functions
/// that ChatBot can do
class ChatBot {
  final logger = Logger("ChatBot");

  /// Starts SpeechToText service in
  /// the android native side and return
  /// the detected text after he finishes.
  Future<String?> askChatBot() {
    logger.log("askChatBot: ChaBot is asking user for his speech...");
    return ChatBotPluginPlatform.instance.askChatBot();
  }

  Future<Action?> identifyAction(String text) {
    logger.log("identifyAction: Identifying action '$text'...");
    return ChatBotPluginPlatform.instance.identifyAction(text);
  }

  Future<T?> performAction<T>(Action action, [List<dynamic> args = const []]) {
    logger.log("performAction: Performing '${action.name}' at '${action.methodName}' with args '$args'.");
    return ChatBotPluginPlatform.instance.performAction(action, args);
  }
}
