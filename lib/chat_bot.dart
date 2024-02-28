
import 'chat_bot_platform_interface.dart';

class ChatBot {
  Future<String?> getPlatformVersion() {
    return ChatBotPlatform.instance.getPlatformVersion();
  }
}
