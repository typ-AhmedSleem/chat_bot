import 'package:flutter_test/flutter_test.dart';
import 'package:chat_bot/chat_bot.dart';
import 'package:chat_bot/chat_bot_platform_interface.dart';
import 'package:chat_bot/chat_bot_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockChatBotPlatform
    with MockPlatformInterfaceMixin
    implements ChatBotPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final ChatBotPlatform initialPlatform = ChatBotPlatform.instance;

  test('$MethodChannelChatBot is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelChatBot>());
  });

  test('getPlatformVersion', () async {
    ChatBot chatBotPlugin = ChatBot();
    MockChatBotPlatform fakePlatform = MockChatBotPlatform();
    ChatBotPlatform.instance = fakePlatform;

    expect(await chatBotPlugin.getPlatformVersion(), '42');
  });
}
