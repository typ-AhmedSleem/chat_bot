import 'chat_bot_platform_interface.dart';

class ChatBot {

  Future<String?> askChatBot() {
    return ChatBotPluginPlatform.instance.askChatBot();
  }

}
