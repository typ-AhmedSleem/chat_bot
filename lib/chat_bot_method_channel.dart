import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'chat_bot_platform_interface.dart';

class MethodChannelChatBotPlugin extends ChatBotPluginPlatform {
  @visibleForTesting
  final methodChannel =
      const MethodChannel('com.typ.chat_bot.channels.ChatBot');

  /// Starts SpeechToText service in
  /// the android native side and return
  /// the detected text after he finishes.
  @override
  Future<String?> askChatBot() async {
    final speech = await methodChannel.invokeMethod<String?>('startVoiceInput');
    return speech;
  }
}
