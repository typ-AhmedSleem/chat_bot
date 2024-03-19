import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'chat_bot_platform_interface.dart';

class MethodChannelChatBotPlugin extends ChatBotPluginPlatform {

  @visibleForTesting
  final methodChannel = const MethodChannel('com.typ.chat_bot.channels.ChatBot');

  @override
  Future<String?> askChatBot() async {
    final speech = await methodChannel.invokeMethod<String?>('startVoiceInput');
    return speech;
  }

}
