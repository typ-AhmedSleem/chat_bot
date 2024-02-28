import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'chat_bot_method_channel.dart';

abstract class ChatBotPlatform extends PlatformInterface {
  /// Constructs a ChatBotPlatform.
  ChatBotPlatform() : super(token: _token);

  static final Object _token = Object();

  static ChatBotPlatform _instance = MethodChannelChatBot();

  /// The default instance of [ChatBotPlatform] to use.
  ///
  /// Defaults to [MethodChannelChatBot].
  static ChatBotPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [ChatBotPlatform] when
  /// they register themselves.
  static set instance(ChatBotPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
