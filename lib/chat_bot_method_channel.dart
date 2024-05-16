import 'dart:ffi';

import 'package:chat_bot/actions/actions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'chat_bot_platform_interface.dart';

class MethodChannelChatBotPlugin extends ChatBotPluginPlatform {
  @visibleForTesting
  final methodChannel = const MethodChannel('com.typ.chat_bot.channels.ChatBot');

  /// Starts SpeechToText service in
  /// the android native side and return
  /// the detected text after he finishes.
  @override
  Future<String?> askChatBot() async {
    return await methodChannel.invokeMethod<String?>('startVoiceInput');
  }

  @override
  Future<Action?> identifyAction(String text) async {
    final actionName = await methodChannel.invokeMethod('identifyAction', text) as String?;
    if (actionName == null) return null;

    final action = Action.getActionByName(actionName);
    if (action is UnknownAction) return null;
    return action;
  }

  @override
  Future<Void?> performAction(Action action, [List args = const []]) async {
    return await methodChannel.invokeMethod(action.methodName, args);
  }
}
