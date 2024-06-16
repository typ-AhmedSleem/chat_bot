import 'actions/actions.dart';
import 'api/chat_bot_api.dart';
import 'chat_bot_platform_interface.dart';
import 'helpers/logger.dart';

/// Class that holds most functions
/// that ChatBot can do
class ChatBot {
  final logger = Logger("ChatBot");
  final api = PatientAPI();

  /// Starts SpeechToText service in
  /// the android native side and return
  /// the detected text after he finishes.
  Future<String?> askChatBot({bool throws = true}) async {
    logger.log("askChatBot: ChaBot is asking user for his speech...");
    try {
      return ChatBotPluginPlatform.instance.askChatBot();
    } catch (e) {
      if (throws) {
        rethrow;
      } else {
        return null;
      }
    }
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
