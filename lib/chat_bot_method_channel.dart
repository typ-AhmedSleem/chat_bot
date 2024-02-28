import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'chat_bot_platform_interface.dart';

/// An implementation of [ChatBotPlatform] that uses method channels.
class MethodChannelChatBot extends ChatBotPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('chat_bot');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
