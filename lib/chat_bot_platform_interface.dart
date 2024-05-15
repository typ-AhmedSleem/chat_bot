import 'package:chat_bot/actions/action.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'chat_bot_method_channel.dart';

abstract class ChatBotPluginPlatform extends PlatformInterface {

  ChatBotPluginPlatform() : super(token: _token);

  static final Object _token = Object();

  static ChatBotPluginPlatform _instance = MethodChannelChatBotPlugin();

  static ChatBotPluginPlatform get instance => _instance;

  static set instance(ChatBotPluginPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

/// Starts SpeechToText service in 
/// the android native side and return
/// the detected text after he finishes.
Future<String?> askChatBot() {
  throw UnimplementedError("askChatBot has not been implemented yet.");
}

/// Gives text to the chat bot to be classified
/// and returns the identified action to be done
///
Future<Action?> identifyAction(String text) {
    throw UnimplementedError("askChatBot has not been implemented yet.");
}

// todo: Create method: performAction(Action action)

}
