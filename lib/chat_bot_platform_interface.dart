import 'package:chat_bot/actions/actions.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'chat_bot_method_channel.dart';

abstract class ChatBotPluginPlatform extends PlatformInterface {
  ChatBotPluginPlatform() : super(token: _token);

  static final Object _token = Object();

  static ChatBotPluginPlatform _instance = ChatBotPlugin();

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
  Future<Action?> identifyAction(String text) {
    throw UnimplementedError("identifyAction has not been implemented yet.");
  }

  /// Performs the given action with given args
  /// on the native platform
// Future<T?> performAction<T>(Action action, [List<dynamic> args = const []]) {
//   throw UnimplementedError("performAction has not been implemented yet.");
// }
}
